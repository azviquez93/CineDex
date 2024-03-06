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
  
  @Published var sortOption: SortOption = .created
  @Published var sortMode: SortMode = .descending
  
  var sortDescriptor: NSSortDescriptor = .init(key: "createdAt", ascending: false)
  
  func updateSortDescriptor() {
    var ascending: Bool
    switch sortMode {
    case .ascending: ascending = true
    case .descending: ascending = false
    }
    switch sortOption {
    case .year: sortDescriptor = NSSortDescriptor(key: "metadata.year", ascending: ascending)
    case .created: sortDescriptor = NSSortDescriptor(key: "createdAt", ascending: ascending)
    case .title: sortDescriptor = NSSortDescriptor(key: "metadata.originalTitle", ascending: ascending)
    case .imdbRating: sortDescriptor = NSSortDescriptor(key: "imdb.siteRatingValue", ascending: ascending)
    }
    refreshMovies()
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
