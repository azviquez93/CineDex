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
  
  @Published var selectedDirectors: [String] = []
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
    if let genresPredicate = genresPredicate() {
      predicates.append(genresPredicate)
    }
    
    // Add the genre predicate
    if let directorsPredicate = directorsPredicate() {
      predicates.append(directorsPredicate)
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
  
  private func genresPredicate() -> NSPredicate? {
    guard !selectedGenres.isEmpty else {
      return nil
    }
    return NSPredicate(format: "ANY genres.genre.name IN %@", selectedGenres)
  }
  
  private func directorsPredicate() -> NSPredicate? {
    guard !selectedDirectors.isEmpty else {
      return nil
    }
    return NSPredicate(format: "ANY directors.director.person.name IN %@", selectedDirectors)
    
  }
  
}
