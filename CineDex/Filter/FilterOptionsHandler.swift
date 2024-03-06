import Foundation

@MainActor
final class FilterOptionsHandler: ObservableObject {
  @Published var genresListViewModel: GenresListViewModel
  @Published var directorsListViewModel: DirectorsListViewModel
  @Published var starsListViewModel: StarsListViewModel
  @Published var writersListViewModel: WritersListViewModel
  @Published var contentRatingsListViewModel: ContentRatingsListViewModel
  @Published var studiosListViewModel: StudiosListViewModel
  @Published var countriesListViewModel: CountriesListViewModel
  
  static let shared = FilterOptionsHandler()
  
  init() {
    genresListViewModel = GenresListViewModel()
    directorsListViewModel = DirectorsListViewModel()
    starsListViewModel = StarsListViewModel()
    writersListViewModel = WritersListViewModel()
    contentRatingsListViewModel = ContentRatingsListViewModel()
    studiosListViewModel = StudiosListViewModel()
    countriesListViewModel = CountriesListViewModel()
  }
  
  func refreshFilters() {
    genresListViewModel.refreshGenres(keepSelection: false, reset: true)
    directorsListViewModel.refreshDirectors(keepSelection: false, reset: true)
    starsListViewModel.refreshStars(keepSelection: false, reset: true)
    writersListViewModel.refreshWriters(keepSelection: false, reset: true)
    contentRatingsListViewModel.refreshContentRatings(keepSelection: false, reset: true)
    studiosListViewModel.refreshStudios(keepSelection: false, reset: true)
    countriesListViewModel.refreshCountries(keepSelection: false, reset: true)
  }
}
