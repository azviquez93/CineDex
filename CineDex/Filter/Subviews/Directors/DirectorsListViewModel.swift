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
  
  func refreshDirectors() {
    let persistenceController = PersistenceController.shared
    let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
    let genres = ["Short"]
    fetchRequest.predicate = NSPredicate(format: "ANY genres.genre.name IN %@", genres)
    do {
      let moviesWithGenre = try persistenceController.container.viewContext.fetch(fetchRequest)
      let directorsFetchRequest: NSFetchRequest<MovieDirector> = MovieDirector.fetchRequest()
      let directorsPredicate = NSPredicate(format: "ANY movie IN %@", moviesWithGenre)
      directorsFetchRequest.predicate = directorsPredicate
      let sortDescriptor = NSSortDescriptor(key: "director.person.name", ascending: true)
      directorsFetchRequest.sortDescriptors = [sortDescriptor]
      let moviesDirectorsCD = try persistenceController.container.viewContext.fetch(directorsFetchRequest)
      directors = moviesDirectorsCD.map { DirectorData(name: $0.director?.person?.name ?? "Unknown Director", selected: false) }
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
