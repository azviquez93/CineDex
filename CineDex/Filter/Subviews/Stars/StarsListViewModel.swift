import CoreData
import SwiftUI

@MainActor
final class StarsListViewModel: ObservableObject {
  @Published var stars: [StarData] = []
  
  var selectedStarsNames: [String] {
    return stars.filter { $0.selected }.map { $0.name }
  }
  
  var selectedLabel: String {
    let selectedStars = stars.filter { $0.selected }
    if selectedStars.isEmpty {
      return "Ninguno"
    } else {
      let selectedStarNames = selectedStars.map { $0.name }
      return selectedStarNames.joined(separator: ", ")
    }
  }
  
  func refreshStars(keepSelection: Bool, reset: Bool) {
    let persistenceController = PersistenceController.shared
    let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
    
    let genres = FilterOptionsHandler.shared.genresListViewModel.selectedGenresNames
    let directors = FilterOptionsHandler.shared.directorsListViewModel.selectedDirectorsNames
    let writers = FilterOptionsHandler.shared.writersListViewModel.selectedWritersNames
    let contentRatings = FilterOptionsHandler.shared.contentRatingsListViewModel.selectedContentRatingsNames
    let studios = FilterOptionsHandler.shared.studiosListViewModel.selectedStudiosNames
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
    
    if writers.count > 0 && !reset {
      let writersPredicate = NSPredicate(format: "ANY writers.writer.person.name IN %@", writers)
      predicates.append(writersPredicate)
    }
    
    if contentRatings.count > 0 && !reset {
      let contentRatingsPredicate = NSPredicate(format: "ANY contentRating.contentRating.name IN %@", contentRatings)
      predicates.append(contentRatingsPredicate)
    }
    
    if studios.count > 0 && !reset {
      let studiosPredicate = NSPredicate(format: "ANY studio.studio.name IN %@", studios)
      predicates.append(studiosPredicate)
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
      let starsFetchRequest: NSFetchRequest<Star> = Star.fetchRequest()
      if !reset {
        starsFetchRequest.predicate = NSPredicate(format: "ANY movies.movie IN %@", moviesWithFilters)
      }
      let sortDescriptor = NSSortDescriptor(key: "person.name", ascending: true)
      starsFetchRequest.sortDescriptors = [sortDescriptor]
      let starsCD = try persistenceController.container.viewContext.fetch(starsFetchRequest)
      if keepSelection {
        let selectedStars = selectedStarsNames
        stars = starsCD.map { star in
          let isSelected = selectedStars.contains(star.person?.name ?? "")
          return StarData(name: star.person?.name ?? "Unknown Star", selected: isSelected)
        }
      } else {
        stars = starsCD.map { StarData(name: $0.person?.name ?? "Unknown Star", selected: false) }
      }
    } catch {
      print("Error fetching stars: \(error)")
    }
  }
}

struct StarData: Hashable, Identifiable {
  let id = UUID()
  var name: String
  var selected: Bool
  
  init(name: String, selected: Bool) {
    self.name = name
    self.selected = selected
  }
}
