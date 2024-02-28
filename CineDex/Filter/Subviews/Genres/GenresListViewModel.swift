import SwiftUI
import CoreData

@MainActor
final class GenresListViewModel: ObservableObject {
  @Published var genres: [GenreData] = []
  
  var selectedGenresNames: [String] {
    return genres.filter { $0.selected }.map { $0.name }
  }
  
  var selectedLabel: String {
    get {
      let selectedGenres = genres.filter { $0.selected }
      if selectedGenres.isEmpty {
        return "Ninguno"
      } else {
        let selectedGenreNames = selectedGenres.map { $0.name }
        return selectedGenreNames.joined(separator: ", ")
      }
    }
  }
  
  func refreshGenres() {
    let persistenceController = PersistenceController.shared
    let fetchRequest: NSFetchRequest<Genre> = Genre.fetchRequest()
    let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    do {
      let genresCD = try persistenceController.container.viewContext.fetch(fetchRequest)
      genres = genresCD.map { GenreData(name: $0.name ?? "Unknown Genre", selected: false) }
    } catch {
      print("Error fetching movies: \(error)")
    }
  }
}

struct GenreData: Hashable, Identifiable {
  let id = UUID()
  var name: String
  var selected: Bool
  
  init(name: String, selected: Bool) {
    self.name = name
    self.selected = selected
  }
}
