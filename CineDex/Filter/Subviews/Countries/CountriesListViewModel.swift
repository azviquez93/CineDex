import SwiftUI
import CoreData

@MainActor
final class CountriesListViewModel: ObservableObject {
  @Published var countries: [CountryData] = []
  
  var selectedCountriesNames: [String] {
    return countries.filter { $0.selected }.map { $0.name }
  }
  
  var selectedLabel: String {
    get {
      let selectedCountries = countries.filter { $0.selected }
      if selectedCountries.isEmpty {
        return "Ninguno"
      } else {
        let selectedCountryNames = selectedCountries.map { $0.name }
        return selectedCountryNames.joined(separator: ", ")
      }
    }
  }
  
  func refreshCountries(keepSelection: Bool, reset: Bool) {
    let persistenceController = PersistenceController.shared
    let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
    
    let genres = FilterOptionsHandler.shared.genresListViewModel.selectedGenresNames
    let directors = FilterOptionsHandler.shared.directorsListViewModel.selectedDirectorsNames
    let stars = FilterOptionsHandler.shared.starsListViewModel.selectedStarsNames
    let writers = FilterOptionsHandler.shared.writersListViewModel.selectedWritersNames
    let contentRatings = FilterOptionsHandler.shared.contentRatingsListViewModel.selectedContentRatingsNames
    let studios = FilterOptionsHandler.shared.studiosListViewModel.selectedStudiosNames
    var predicates = [NSPredicate]()
    
    if genres.count > 0 && !reset {
        let genresPredicate = NSPredicate(format: "ANY genres.genre.name IN %@", genres)
        predicates.append(genresPredicate)
    }
    
    if directors.count > 0 && !reset {
        let directorsPredicate = NSPredicate(format: "ANY directors.director.person.name IN %@", directors)
        predicates.append(directorsPredicate)
    }

    if stars.count > 0 && !reset {
        let starsPredicate = NSPredicate(format: "ANY stars.star.person.name IN %@", stars)
        predicates.append(starsPredicate)
    }
    
    if writers.count > 0 && !reset {
        let writersPredicate = NSPredicate(format: "ANY writers.writer.person.name IN %@", writers)
        predicates.append(writersPredicate)
    }
    
    if contentRatings.count > 0 && !reset {
        let contentRatingsPredicate = NSPredicate(format: "ANY contentRating.contentRating.name IN %@", contentRatings)
        predicates.append(contentRatingsPredicate)
    }
    
    if studios.count > 0 && !reset {
        let studiosPredicate = NSPredicate(format: "ANY studio.studio.name IN %@", studios)
        predicates.append(studiosPredicate)
    }

    if !predicates.isEmpty {
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fetchRequest.predicate = compoundPredicate
    }
    
    do {
      let moviesWithFilters = try persistenceController.container.viewContext.fetch(fetchRequest)
      let countriesFetchRequest: NSFetchRequest<Country> = Country.fetchRequest()
      if !reset {
        countriesFetchRequest.predicate = NSPredicate(format: "ANY movies.movie IN %@", moviesWithFilters)
      }
      let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
      countriesFetchRequest.sortDescriptors = [sortDescriptor]
      let countriesCD = try persistenceController.container.viewContext.fetch(countriesFetchRequest)
      if keepSelection {
        let selectedCountries = selectedCountriesNames
        countries = countriesCD.map { country in
          let isSelected = selectedCountries.contains(country.name ?? "")
          return CountryData(name: country.name ?? "Unknown Country", selected: isSelected)
        }
      }
      else {
        countries = countriesCD.map { CountryData(name: $0.name ?? "Unknown Country", selected: false) }
      }
    } catch {
      print("Error fetching directors: \(error)")
    }
  }
}

struct CountryData: Hashable, Identifiable {
  let id = UUID()
  var name: String
  var selected: Bool
  
  init(name: String, selected: Bool) {
    self.name = name
    self.selected = selected
  }
}
