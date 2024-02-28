import Foundation

@MainActor
final class FilterOptionsHandler: ObservableObject {
  
  @Published var genresListViewModel: GenresListViewModel
  @Published var directorsListViewModel: DirectorsListViewModel
  
  static let shared = FilterOptionsHandler()
  
  init() {
    genresListViewModel = GenresListViewModel()
    directorsListViewModel = DirectorsListViewModel()
  }
  
  func refreshFilters() {
    genresListViewModel.refreshGenres()
    directorsListViewModel.refreshDirectors()
  }
  
}

