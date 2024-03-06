import SwiftUI

struct DirectorsListView: View {
  @State private var searchText: String = ""
  @ObservedObject var directorsListViewModel: DirectorsListViewModel
  @ObservedObject var moviesViewModel: MoviesViewModel
  
  var body: some View {
    VStack {
      List {
        ForEach($directorsListViewModel.directors) { $director in
          if searchText.isEmpty || (director.name.localizedCaseInsensitiveContains(searchText)) {
            DirectorsRow(director: $director, directorsListViewModel: directorsListViewModel, moviesViewModel: moviesViewModel)
          }
        }
      }
      .listStyle(.plain)
      .searchable(text: $searchText, prompt: "Buscar")
      Spacer()
      HStack {
        Button {
          directorsListViewModel.refreshDirectors(keepSelection: false, reset: false)
          FilterOptionsHandler.shared.genresListViewModel.refreshGenres(keepSelection: true, reset: false)
          FilterOptionsHandler.shared.starsListViewModel.refreshStars(keepSelection: true, reset: false)
          FilterOptionsHandler.shared.writersListViewModel.refreshWriters(keepSelection: true, reset: false)
          FilterOptionsHandler.shared.contentRatingsListViewModel.refreshContentRatings(keepSelection: true, reset: false)
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
    .navigationTitle("Director")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct DirectorsRow: View {
  @Binding var director: DirectorData
  @ObservedObject var directorsListViewModel: DirectorsListViewModel
  @ObservedObject var moviesViewModel: MoviesViewModel
  
  var body: some View {
    HStack {
      Text(director.name)
      Spacer()
      if director.selected {
        Image(systemName: "checkmark")
          .foregroundColor(.blue)
      }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      director.selected.toggle()
      FilterOptionsHandler.shared.genresListViewModel.refreshGenres(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.starsListViewModel.refreshStars(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.writersListViewModel.refreshWriters(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.contentRatingsListViewModel.refreshContentRatings(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.studiosListViewModel.refreshStudios(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.countriesListViewModel.refreshCountries(keepSelection: true, reset: false)
      moviesViewModel.refreshMovies()
    }
  }
}
