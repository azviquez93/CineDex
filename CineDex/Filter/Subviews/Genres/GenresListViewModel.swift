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
  
  func refreshGenres(keepSelection: Bool, reset: Bool) {
    let persistenceController = PersistenceController.shared
    let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
    
    let directors = FilterOptionsHandler.shared.directorsListViewModel.selectedDirectorsNames
    let stars = FilterOptionsHandler.shared.starsListViewModel.selectedStarsNames
    var predicates = [NSPredicate]()
    
    if directors.count > 0 && !reset {
        let directorsPredicate = NSPredicate(format: "ANY directors.director.person.name IN %@", directors)
        predicates.append(directorsPredicate)
    }

    if stars.count > 0 && !reset {
        let starsPredicate = NSPredicate(format: "ANY stars.star.person.name IN %@", stars)
        predicates.append(starsPredicate)
    }

    if !predicates.isEmpty {
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = compoundPredicate
    }
    
    do {
      let moviesWithFilters = try persistenceController.container.viewContext.fetch(fetchRequest)
      let genresFetchRequest: NSFetchRequest<Genre> = Genre.fetchRequest()
      if (stars.count > 0  || directors.count > 0) && !reset {
        genresFetchRequest.predicate = NSPredicate(format: "ANY movies.movie IN %@", moviesWithFilters)
      }
      let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
      genresFetchRequest.sortDescriptors = [sortDescriptor]
      let genresCD = try persistenceController.container.viewContext.fetch(genresFetchRequest)
      if keepSelection {
        let selectedGenres = selectedGenresNames
        genres = genresCD.map { genre in
          let isSelected = selectedGenres.contains(genre.name ?? "")
          return GenreData(name: genre.name ?? "Unknown Genre", selected: isSelected)
        }
      }
      else {
        genres = genresCD.map { GenreData(name: $0.name ?? "Unknown Genre", selected: false) }
      }
    } catch {
      print("Error fetching directors: \(error)")
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
