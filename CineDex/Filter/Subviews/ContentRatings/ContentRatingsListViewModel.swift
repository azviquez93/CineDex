import CoreData
import SwiftUI

@MainActor
final class ContentRatingsListViewModel: ObservableObject {
  @Published var contentRatings: [ContentRatingData] = []
  
  var selectedContentRatingsNames: [String] {
    return contentRatings.filter { $0.selected }.map { $0.name }
  }
  
  var selectedLabel: String {
    let selectedContentRatings = contentRatings.filter { $0.selected }
    if selectedContentRatings.isEmpty {
      return "Ninguno"
    } else {
      let selectedContentRatingNames = selectedContentRatings.map { $0.name }
      return selectedContentRatingNames.joined(separator: ", ")
    }
  }
  
  func refreshContentRatings(keepSelection: Bool, reset: Bool) {
    let persistenceController = PersistenceController.shared
    let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
    
    let genres = FilterOptionsHandler.shared.genresListViewModel.selectedGenresNames
    let directors = FilterOptionsHandler.shared.directorsListViewModel.selectedDirectorsNames
    let stars = FilterOptionsHandler.shared.starsListViewModel.selectedStarsNames
    let writers = FilterOptionsHandler.shared.writersListViewModel.selectedWritersNames
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

    if stars.count > 0 && !reset {
      let starsPredicate = NSPredicate(format: "ANY stars.star.person.name IN %@", stars)
      predicates.append(starsPredicate)
    }
    
    if writers.count > 0 && !reset {
      let writersPredicate = NSPredicate(format: "ANY writers.writer.person.name IN %@", writers)
      predicates.append(writersPredicate)
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
      let contentRatingsFetchRequest: NSFetchRequest<ContentRating> = ContentRating.fetchRequest()
      if !reset {
        contentRatingsFetchRequest.predicate = NSPredicate(format: "ANY movies.movie IN %@", moviesWithFilters)
      }
      let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
      contentRatingsFetchRequest.sortDescriptors = [sortDescriptor]
      let contentRatingsCD = try persistenceController.container.viewContext.fetch(contentRatingsFetchRequest)
      if keepSelection {
        let selectedContentRatings = selectedContentRatingsNames
        contentRatings = contentRatingsCD.map { contentRating in
          let isSelected = selectedContentRatings.contains(contentRating.name ?? "")
          return ContentRatingData(name: contentRating.name ?? "Unknown ContentRating", selected: isSelected)
        }
      } else {
        contentRatings = contentRatingsCD.map { ContentRatingData(name: $0.name ?? "Unknown ContentRating", selected: false) }
      }
    } catch {
      print("Error fetching directors: \(error)")
    }
  }
}

struct ContentRatingData: Hashable, Identifiable {
  let id = UUID()
  var name: String
  var selected: Bool
  
  init(name: String, selected: Bool) {
    self.name = name
    self.selected = selected
  }
}
