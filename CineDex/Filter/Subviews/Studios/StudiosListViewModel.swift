import CoreData
import SwiftUI

@MainActor
final class StudiosListViewModel: ObservableObject {
  @Published var studios: [StudioData] = []
  
  var selectedStudiosNames: [String] {
    return studios.filter { $0.selected }.map { $0.name }
  }
  
  var selectedLabel: String {
    let selectedStudios = studios.filter { $0.selected }
    if selectedStudios.isEmpty {
      return "Ninguno"
    } else {
      let selectedStudioNames = selectedStudios.map { $0.name }
      return selectedStudioNames.joined(separator: ", ")
    }
  }
  
  func refreshStudios(keepSelection: Bool, reset: Bool) {
    let persistenceController = PersistenceController.shared
    let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
    
    let genres = FilterOptionsHandler.shared.genresListViewModel.selectedGenresNames
    let directors = FilterOptionsHandler.shared.directorsListViewModel.selectedDirectorsNames
    let stars = FilterOptionsHandler.shared.starsListViewModel.selectedStarsNames
    let writers = FilterOptionsHandler.shared.writersListViewModel.selectedWritersNames
    let contentRatings = FilterOptionsHandler.shared.contentRatingsListViewModel.selectedContentRatingsNames
    let countries = FilterOptionsHandler.shared.countriesListViewModel.selectedCountriesNames
    var predicates = [NSPredicate]()
    
    if genres.count > 0 && !reset {
      let genresPredicate = NSPredicate(format: "ANY genres.genre.name IN %@", genres)
      predicates.append(genresPredicate)
    }
    
    if directors.count > 0 && !reset {
      let directorsPredicate = NSPredicate(format: "ANY directors.director.person.name IN %@", directors)
      predicates.append(directorsPredicate)
    }

    if stars.count > 0 && !reset {
      let starsPredicate = NSPredicate(format: "ANY stars.star.person.name IN %@", stars)
      predicates.append(starsPredicate)
    }
    
    if writers.count > 0 && !reset {
      let writersPredicate = NSPredicate(format: "ANY writers.writer.person.name IN %@", writers)
      predicates.append(writersPredicate)
    }
    
    if contentRatings.count > 0 && !reset {
      let contentRatingsPredicate = NSPredicate(format: "ANY contentRating.contentRating.name IN %@", contentRatings)
      predicates.append(contentRatingsPredicate)
    }
    
    if countries.count > 0 && !reset {
      let countriesPredicate = NSPredicate(format: "ANY countries.country.name IN %@", countries)
      predicates.append(countriesPredicate)
    }

    if !predicates.isEmpty {
      let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
      fetchRequest.predicate = compoundPredicate
    }
    
    do {
      let moviesWithFilters = try persistenceController.container.viewContext.fetch(fetchRequest)
      let studiosFetchRequest: NSFetchRequest<Studio> = Studio.fetchRequest()
      if !reset {
        studiosFetchRequest.predicate = NSPredicate(format: "ANY movies.movie IN %@", moviesWithFilters)
      }
      let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
      studiosFetchRequest.sortDescriptors = [sortDescriptor]
      let studiosCD = try persistenceController.container.viewContext.fetch(studiosFetchRequest)
      if keepSelection {
        let selectedStudios = selectedStudiosNames
        studios = studiosCD.map { studio in
          let isSelected = selectedStudios.contains(studio.name ?? "")
          return StudioData(name: studio.name ?? "Unknown Studio", selected: isSelected)
        }
      } else {
        studios = studiosCD.map { StudioData(name: $0.name ?? "Unknown Studio", selected: false) }
      }
    } catch {
      print("Error fetching directors: \(error)")
    }
  }
}

struct StudioData: Hashable, Identifiable {
  let id = UUID()
  var name: String
  var selected: Bool
  
  init(name: String, selected: Bool) {
    self.name = name
    self.selected = selected
  }
}
