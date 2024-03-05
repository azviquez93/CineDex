import SwiftUI

struct ContentRatingsListView: View {
  @State private var searchText: String = ""
  @ObservedObject var contentRatingsListViewModel: ContentRatingsListViewModel
  @ObservedObject var moviesViewModel: MoviesViewModel
  
  var body: some View {
    VStack {
      List {
        ForEach($contentRatingsListViewModel.contentRatings) { $contentRating in
          if searchText.isEmpty || (contentRating.name.localizedCaseInsensitiveContains(searchText)) {
            ContentRatingsRow(contentRating: $contentRating, contentRatingsListViewModel: contentRatingsListViewModel, moviesViewModel: moviesViewModel)
          }
        }
      }
      .listStyle(.plain)
      .searchable(text: $searchText, prompt: "Buscar")
      Spacer()
      HStack {
          Button {
            contentRatingsListViewModel.refreshContentRatings(keepSelection: false, reset: false)
            FilterOptionsHandler.shared.genresListViewModel.refreshGenres(keepSelection: true, reset: false)
            FilterOptionsHandler.shared.directorsListViewModel.refreshDirectors(keepSelection: true, reset: false)
            FilterOptionsHandler.shared.starsListViewModel.refreshStars(keepSelection: true, reset: false)
            FilterOptionsHandler.shared.writersListViewModel.refreshWriters(keepSelection: true, reset: false)
            FilterOptionsHandler.shared.studiosListViewModel.refreshStudios(keepSelection: true, reset: false)
            FilterOptionsHandler.shared.countriesListViewModel.refreshCountries(keepSelection: true, reset: false)
            moviesViewModel.refreshMovies()
          } label: {
              Text("Restablecer")
              .foregroundColor(.red)
          }
          .padding()
      }
    }
    .navigationTitle("Género")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct ContentRatingsRow: View {
  @Binding var contentRating: ContentRatingData
  @ObservedObject var contentRatingsListViewModel: ContentRatingsListViewModel
  @ObservedObject var moviesViewModel: MoviesViewModel
  
  var body: some View {
    HStack {
      Text(contentRating.name)
      Spacer()
      if contentRating.selected {
        Image(systemName: "checkmark")
          .foregroundColor(.blue)
        
      }
      
    }
    .contentShape(Rectangle())
    .onTapGesture {
      contentRating.selected.toggle()
      FilterOptionsHandler.shared.genresListViewModel.refreshGenres(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.directorsListViewModel.refreshDirectors(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.starsListViewModel.refreshStars(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.writersListViewModel.refreshWriters(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.studiosListViewModel.refreshStudios(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.countriesListViewModel.refreshCountries(keepSelection: true, reset: false)
      moviesViewModel.refreshMovies()
    }
  }
}
