//
//  MoviesViewModel.swift
//  plex_client_macos
//
//  Created by Andrés Zamora on 23/11/23.
//

import SwiftUI
import CoreData

@MainActor
final class MoviesViewModel: ObservableObject {
  
  @Published var selectedGenres: [String] = []
  @Published var movies: [Movie] = []
  @Published var searchText: String = "" {
    didSet {
      refreshMovies()
    }
  }
  
  func formattedYear(year: Int16?) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .none
    
    return numberFormatter.string(from: NSNumber(value: year ?? 0)) ?? ""
  }
  
  func refreshMovies() {
    // Fetch data from Core Data
    let persistenceController = PersistenceController.shared
    let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
    
    // Add a sort descriptor to the fetch request
    let sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: false) // Change 'true' to 'false' for descending order
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    // Create a predicate to filter based on the search text
    var predicates: [NSPredicate] = []
    
    if !searchText.isEmpty {
      let titlePredicate = NSPredicate(format: "metadata.originalTitle CONTAINS[cd] %@", searchText)
      let alternativeTitlePredicate = NSPredicate(format: "metadata.alternativeTitle CONTAINS[cd] %@", searchText)
      
      // Combine the predicates using OR
      let orPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, alternativeTitlePredicate])
      predicates.append(orPredicate)
    }
    
    // Add the genre predicate
    if let genrePredicate = genrePredicate() {
      predicates.append(genrePredicate)
    }
    
    // Combine all predicates using AND
    let finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    fetchRequest.predicate = finalPredicate
    
    do {
      self.movies = try persistenceController.container.viewContext.fetch(fetchRequest)
    } catch {
      print("Error fetching movies: \(error)")
    }
  }
  
  private func genrePredicate() -> NSPredicate? {
    guard !selectedGenres.isEmpty else {
      return nil
    }
    
    // Use SUBQUERY to filter movies based on the selected genres
    let subquery = NSPredicate(format: "SUBQUERY(genres, $genre, $genre.name IN %@).@count > 0", selectedGenres)
    
    return subquery
  }
  
}
