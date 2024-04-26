//
//  MoviesViewModel.swift
//  plex_client_macos
//
//  Created by Andrés Zamora on 23/11/23.
//

import CoreData
import SwiftUI

@MainActor
final class MoviesViewModel: ObservableObject {
  @Published var movies: [Movie] = []
  @Published var searchText: String = "" {
    didSet {
      refreshMovies()
    }
  }
  
  @AppStorage("sortOption") var sortOption: SortOption = .created
  @AppStorage("sortMode") var sortMode: SortMode = .descending
  
  var sortDescriptor: NSSortDescriptor?
  
  func updateSortDescriptor() {
    var ascending: Bool
    switch sortMode {
    case .ascending: ascending = true
    case .descending: ascending = false
    }
    switch sortOption {
    case .year: sortDescriptor = NSSortDescriptor(key: "metadata.year", ascending: ascending)
    case .created: sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: ascending)
    case .title: sortDescriptor = NSSortDescriptor(key: "metadata.title", ascending: ascending)
    case .rating:
      if let storedRating = UserDefaults.standard.string(forKey: "rating"),
         let rawValue = Int(storedRating) {
         let selectedRating = Rating(rawValue: rawValue)
        switch selectedRating {
        case .imdb:
          sortDescriptor = NSSortDescriptor(key: "imdb.siteRatingValue", ascending: ascending)
        case .rottentomatoesSite:
          sortDescriptor = NSSortDescriptor(key: "rottentomatoes.siteRatingValue", ascending: ascending)
        case .rottentomatoesUsers:
          sortDescriptor = NSSortDescriptor(key: "rottentomatoes.userRatingValue", ascending: ascending)
        case .metacriticSite:
          sortDescriptor = NSSortDescriptor(key: "metacritic.siteRatingValue", ascending: ascending)
        case .metacriticUsers:
          sortDescriptor = NSSortDescriptor(key: "metacritic.userRatingValue", ascending: ascending)
        case .filmaffinity:
          sortDescriptor = NSSortDescriptor(key: "filmaffinity.siteRatingValue", ascending: ascending)
        case .letterboxd:
          sortDescriptor = NSSortDescriptor(key: "letterboxd.siteRatingValue", ascending: ascending)
        case .none:
          sortDescriptor = NSSortDescriptor(key: "imdb.siteRatingValue", ascending: ascending)
        }
      }
      else {
        sortDescriptor = NSSortDescriptor(key: "imdb.siteRatingValue", ascending: ascending)
      }
      
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
    updateSortDescriptor()
    if let sortDescriptor = sortDescriptor {
      fetchRequest.sortDescriptors = [sortDescriptor]
    }
    
    // Create a predicate to filter based on the search text
    var predicates: [NSPredicate] = []
    
    if !searchText.isEmpty {
      let titlePredicate = NSPredicate(format: "metadata.title CONTAINS[cd] %@", searchText)
      let alternativeTitlePredicate = NSPredicate(format: "metadata.originalTitle CONTAINS[cd] %@", searchText)
      
      // Combine the predicates using OR
      let orPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titlePredicate, alternativeTitlePredicate])
      predicates.append(orPredicate)
    }
    
    if let genresPredicate = genresPredicate() {
      predicates.append(genresPredicate)
    }
    
    if let directorsPredicate = directorsPredicate() {
      predicates.append(directorsPredicate)
    }
    
    if let starsPredicate = starsPredicate() {
      predicates.append(starsPredicate)
    }
    
    if let writersPredicate = writersPredicate() {
      predicates.append(writersPredicate)
    }
    
    if let contentRatingsPredicate = contentRatingsPredicate() {
      predicates.append(contentRatingsPredicate)
    }
    
    if let studiosPredicate = studiosPredicate() {
      predicates.append(studiosPredicate)
    }
    
    if let countriesPredicate = countriesPredicate() {
      predicates.append(countriesPredicate)
    }
    
    let finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    fetchRequest.predicate = finalPredicate
    
    do {
      movies = try persistenceController.container.viewContext.fetch(fetchRequest)
    } catch {
      print("Error fetching movies: \(error)")
    }
  }
  
  private func genresPredicate() -> NSPredicate? {
    let selectedGenres = FilterOptionsHandler.shared.genresListViewModel.selectedGenresNames
    guard !selectedGenres.isEmpty else {
      return nil
    }
    return NSPredicate(format: "ANY genres.genre.name IN %@", selectedGenres)
  }
  
  private func directorsPredicate() -> NSPredicate? {
    let selectedDirectors = FilterOptionsHandler.shared.directorsListViewModel.selectedDirectorsNames
    guard !selectedDirectors.isEmpty else {
      return nil
    }
    return NSPredicate(format: "ANY directors.director.person.name IN %@", selectedDirectors)
  }
  
  private func starsPredicate() -> NSPredicate? {
    let selectedStars = FilterOptionsHandler.shared.starsListViewModel.selectedStarsNames
    guard !selectedStars.isEmpty else {
      return nil
    }
    return NSPredicate(format: "ANY stars.star.person.name IN %@", selectedStars)
  }
  
  private func writersPredicate() -> NSPredicate? {
    let selectedWriters = FilterOptionsHandler.shared.writersListViewModel.selectedWritersNames
    guard !selectedWriters.isEmpty else {
      return nil
    }
    return NSPredicate(format: "ANY writers.writer.person.name IN %@", selectedWriters)
  }
  
  private func contentRatingsPredicate() -> NSPredicate? {
    let selectedContentRatings = FilterOptionsHandler.shared.contentRatingsListViewModel.selectedContentRatingsNames
    guard !selectedContentRatings.isEmpty else {
      return nil
    }
    return NSPredicate(format: "ANY contentRating.contentRating.name IN %@", selectedContentRatings)
  }
  
  private func studiosPredicate() -> NSPredicate? {
    let selectedStudios = FilterOptionsHandler.shared.studiosListViewModel.selectedStudiosNames
    guard !selectedStudios.isEmpty else {
      return nil
    }
    return NSPredicate(format: "ANY studio.studio.name IN %@", selectedStudios)
  }
  
  private func countriesPredicate() -> NSPredicate? {
    let selectedCountries = FilterOptionsHandler.shared.countriesListViewModel.selectedCountriesNames
    guard !selectedCountries.isEmpty else {
      return nil
    }
    return NSPredicate(format: "ANY countries.country.name IN %@", selectedCountries)
  }
}
