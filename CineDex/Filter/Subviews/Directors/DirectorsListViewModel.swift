import SwiftUI
import CoreData

@MainActor
final class DirectorsListViewModel: ObservableObject {
  @Published var directors: [DirectorData] = []
  
  var selectedDirectorsNames: [String] {
    return directors.filter { $0.selected }.map { $0.name }
  }
  
  var selectedLabel: String {
    get {
      let selectedDirectors = directors.filter { $0.selected }
      if selectedDirectors.isEmpty {
        return "Ninguno"
      } else {
        let selectedDirectorNames = selectedDirectors.map { $0.name }
        return selectedDirectorNames.joined(separator: ", ")
      }
    }
  }
  
  func refreshDirectors(keepSelection: Bool, reset: Bool) {
    let persistenceController = PersistenceController.shared
    let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
    
    let genres = FilterOptionsHandler.shared.genresListViewModel.selectedGenresNames
    let stars = FilterOptionsHandler.shared.starsListViewModel.selectedStarsNames
    let writers = FilterOptionsHandler.shared.writersListViewModel.selectedWritersNames
    var predicates = [NSPredicate]()
    
    if genres.count > 0 && !reset {
        let genresPredicate = NSPredicate(format: "ANY genres.genre.name IN %@", genres)
        predicates.append(genresPredicate)
    }
    if stars.count > 0 && !reset {
        let starsPredicate = NSPredicate(format: "ANY stars.star.person.name IN %@", stars)
        predicates.append(starsPredicate)
    }
    if writers.count > 0 && !reset {
        let writersPredicate = NSPredicate(format: "ANY writers.writer.person.name IN %@", writers)
        predicates.append(writersPredicate)
    }
    
    if !predicates.isEmpty {
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = compoundPredicate
    }
    
    do {
      let moviesWithFilters = try persistenceController.container.viewContext.fetch(fetchRequest)
      let directorsFetchRequest: NSFetchRequest<Director> = Director.fetchRequest()
      if !reset {
        directorsFetchRequest.predicate = NSPredicate(format: "ANY movies.movie IN %@", moviesWithFilters)
      }
      let sortDescriptor = NSSortDescriptor(key: "person.name", ascending: true)
      directorsFetchRequest.sortDescriptors = [sortDescriptor]
      let directorsCD = try persistenceController.container.viewContext.fetch(directorsFetchRequest)
      if keepSelection {
        let selectedDirectors = selectedDirectorsNames
        directors = directorsCD.map { director in
          let isSelected = selectedDirectors.contains(director.person?.name ?? "")
          return DirectorData(name: director.person?.name ?? "Unknown Director", selected: isSelected)
        }
      }
      else {
        directors = directorsCD.map { DirectorData(name: $0.person?.name ?? "Unknown Director", selected: false) }
      }
    } catch {
      print("Error fetching directors: \(error)")
    }
  }
  
  
}

struct DirectorData: Hashable, Identifiable {
  let id = UUID()
  var name: String
  var selected: Bool
  
  init(name: String, selected: Bool) {
    self.name = name
    self.selected = selected
  }
}
