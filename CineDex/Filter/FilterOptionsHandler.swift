import Foundation

@MainActor
final class FilterOptionsHandler: ObservableObject {
  
  @Published var genresListViewModel: GenresListViewModel
  @Published var directorsListViewModel: DirectorsListViewModel
  @Published var starsListViewModel: StarsListViewModel
  @Published var writersListViewModel: WritersListViewModel
  
  static let shared = FilterOptionsHandler()
  
  init() {
    genresListViewModel = GenresListViewModel()
    directorsListViewModel = DirectorsListViewModel()
    starsListViewModel = StarsListViewModel()
    writersListViewModel = WritersListViewModel()
  }
  
  func refreshFilters() {
    genresListViewModel.refreshGenres(keepSelection: false, reset: true)
    directorsListViewModel.refreshDirectors(keepSelection: false, reset: true)
    starsListViewModel.refreshStars(keepSelection: false, reset: true)
    writersListViewModel.refreshWriters(keepSelection: false, reset: true)
  }
  
}

