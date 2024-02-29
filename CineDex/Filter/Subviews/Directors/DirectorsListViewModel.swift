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
    if genres.count > 0 && !reset {
      // If genres are selected, filter movies by these genres
      fetchRequest.predicate = NSPredicate(format: "ANY genres.genre.name IN %@", genres)
    } else {
      // If no genres are selected, do not apply a genre filter
      fetchRequest.predicate = nil
    }
    
    do {
      let moviesWithGenre = try persistenceController.container.viewContext.fetch(fetchRequest)
      let directorsFetchRequest: NSFetchRequest<Director> = Director.fetchRequest()
      if genres.count > 0 && !reset {
        let directorsPredicate = NSPredicate(format: "ANY movies.movie IN %@", moviesWithGenre)
        directorsFetchRequest.predicate = directorsPredicate
      } else {
        // If no genres are selected, do not apply a movie filter
        directorsFetchRequest.predicate = nil
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