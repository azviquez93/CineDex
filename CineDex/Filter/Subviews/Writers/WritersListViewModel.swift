import CoreData
import SwiftUI

@MainActor
final class WritersListViewModel: ObservableObject {
  @Published var writers: [WriterData] = []
  
  var selectedWritersNames: [String] {
    return writers.filter { $0.selected }.map { $0.name }
  }
  
  var selectedLabel: String {
    let selectedWriters = writers.filter { $0.selected }
    if selectedWriters.isEmpty {
      return "Ninguno"
    } else {
      let selectedWriterNames = selectedWriters.map { $0.name }
      return selectedWriterNames.joined(separator: ", ")
    }
  }
  
  func refreshWriters(keepSelection: Bool, reset: Bool) {
    let persistenceController = PersistenceController.shared
    let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
    
    let genres = FilterOptionsHandler.shared.genresListViewModel.selectedGenresNames
    let directors = FilterOptionsHandler.shared.directorsListViewModel.selectedDirectorsNames
    let stars = FilterOptionsHandler.shared.starsListViewModel.selectedStarsNames
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
    
    if stars.count > 0 && !reset {
      let starsPredicate = NSPredicate(format: "ANY stars.star.person.name IN %@", stars)
      predicates.append(starsPredicate)
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
      let writersFetchRequest: NSFetchRequest<Writer> = Writer.fetchRequest()
      if !reset {
        writersFetchRequest.predicate = NSPredicate(format: "ANY movies.movie IN %@", moviesWithFilters)
      }
      let sortDescriptor = NSSortDescriptor(key: "person.name", ascending: true)
      writersFetchRequest.sortDescriptors = [sortDescriptor]
      let writersCD = try persistenceController.container.viewContext.fetch(writersFetchRequest)
      if keepSelection {
        let selectedWriters = selectedWritersNames
        writers = writersCD.map { writer in
          let isSelected = selectedWriters.contains(writer.person?.name ?? "")
          return WriterData(name: writer.person?.name ?? "Unknown Writer", selected: isSelected)
        }
      } else {
        writers = writersCD.map { WriterData(name: $0.person?.name ?? "Unknown Writer", selected: false) }
      }
    } catch {
      print("Error fetching writers: \(error)")
    }
  }
}

struct WriterData: Hashable, Identifiable {
  let id = UUID()
  var name: String
  var selected: Bool
  
  init(name: String, selected: Bool) {
    self.name = name
    self.selected = selected
  }
}
