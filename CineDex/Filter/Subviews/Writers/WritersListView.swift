import SwiftUI

struct WritersListView: View {
  @State private var searchText: String = ""
  @ObservedObject var writersListViewModel: WritersListViewModel
  @ObservedObject var moviesViewModel: MoviesViewModel
  
  var body: some View {
    VStack {
      List {
        ForEach($writersListViewModel.writers) { $writer in
          if searchText.isEmpty || (writer.name.localizedCaseInsensitiveContains(searchText)) {
            WritersRow(writer: $writer, writersListViewModel: writersListViewModel, moviesViewModel: moviesViewModel)
          }
        }
      }
      .listStyle(.plain)
      .searchable(text: $searchText, prompt: "Buscar")
      Spacer()
      HStack {
        Button {
          writersListViewModel.refreshWriters(keepSelection: false, reset: false)
          FilterOptionsHandler.shared.genresListViewModel.refreshGenres(keepSelection: true, reset: false)
          FilterOptionsHandler.shared.directorsListViewModel.refreshDirectors(keepSelection: true, reset: false)
          FilterOptionsHandler.shared.starsListViewModel.refreshStars(keepSelection: true, reset: false)
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
    .navigationTitle("Guionistas")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct WritersRow: View {
  @Binding var writer: WriterData
  @ObservedObject var writersListViewModel: WritersListViewModel
  @ObservedObject var moviesViewModel: MoviesViewModel
  
  var body: some View {
    HStack {
      Text(writer.name)
      Spacer()
      if writer.selected {
        Image(systemName: "checkmark")
          .foregroundColor(.blue)
      }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      writer.selected.toggle()
      FilterOptionsHandler.shared.genresListViewModel.refreshGenres(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.directorsListViewModel.refreshDirectors(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.starsListViewModel.refreshStars(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.contentRatingsListViewModel.refreshContentRatings(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.studiosListViewModel.refreshStudios(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.countriesListViewModel.refreshCountries(keepSelection: true, reset: false)
      moviesViewModel.refreshMovies()
    }
  }
}
