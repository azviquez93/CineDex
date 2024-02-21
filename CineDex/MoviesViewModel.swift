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
  
  @Published var movies: [Movie] = []
  
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
    
    do {
      self.movies = try persistenceController.container.viewContext.fetch(fetchRequest)
    } catch {
      print("Error fetching movies: \(error)")
    }
  }
  
}
