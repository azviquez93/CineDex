import SwiftUI

struct StudiosListView: View {
  @State private var searchText: String = ""
  @ObservedObject var studiosListViewModel: StudiosListViewModel
  @ObservedObject var moviesViewModel: MoviesViewModel
  
  var body: some View {
    VStack {
      List {
        ForEach($studiosListViewModel.studios) { $studio in
          if searchText.isEmpty || (studio.name.localizedCaseInsensitiveContains(searchText)) {
            StudiosRow(studio: $studio, studiosListViewModel: studiosListViewModel, moviesViewModel: moviesViewModel)
          }
        }
      }
      .listStyle(.plain)
      .searchable(text: $searchText, prompt: "Buscar")
      Spacer()
      HStack {
        Button {
          studiosListViewModel.refreshStudios(keepSelection: false, reset: false)
          FilterOptionsHandler.shared.genresListViewModel.refreshGenres(keepSelection: true, reset: false)
          FilterOptionsHandler.shared.directorsListViewModel.refreshDirectors(keepSelection: true, reset: false)
          FilterOptionsHandler.shared.starsListViewModel.refreshStars(keepSelection: true, reset: false)
          FilterOptionsHandler.shared.writersListViewModel.refreshWriters(keepSelection: true, reset: false)
          FilterOptionsHandler.shared.contentRatingsListViewModel.refreshContentRatings(keepSelection: true, reset: false)
          FilterOptionsHandler.shared.countriesListViewModel.refreshCountries(keepSelection: true, reset: false)
          moviesViewModel.refreshMovies()
        } label: {
          Text("Restablecer")
            .foregroundColor(.red)
        }
        .padding()
      }
    }
    .navigationTitle("Estudios")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct StudiosRow: View {
  @Binding var studio: StudioData
  @ObservedObject var studiosListViewModel: StudiosListViewModel
  @ObservedObject var moviesViewModel: MoviesViewModel
  
  var body: some View {
    HStack {
      Text(studio.name)
      Spacer()
      if studio.selected {
        Image(systemName: "checkmark")
          .foregroundColor(.blue)
      }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      studio.selected.toggle()
      FilterOptionsHandler.shared.genresListViewModel.refreshGenres(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.directorsListViewModel.refreshDirectors(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.starsListViewModel.refreshStars(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.writersListViewModel.refreshWriters(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.contentRatingsListViewModel.refreshContentRatings(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.countriesListViewModel.refreshCountries(keepSelection: true, reset: false)
      moviesViewModel.refreshMovies()
    }
  }
}
