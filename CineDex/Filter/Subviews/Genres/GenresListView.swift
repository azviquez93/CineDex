import SwiftUI

struct GenresListView: View {
  @State private var searchText: String = ""
  @ObservedObject var genresListViewModel: GenresListViewModel
  @ObservedObject var moviesViewModel: MoviesViewModel
  
  var body: some View {
    VStack {
      List {
        ForEach($genresListViewModel.genres) { $genre in
          if searchText.isEmpty || (genre.name.localizedCaseInsensitiveContains(searchText)) {
            GenresRow(genre: $genre, genresListViewModel: genresListViewModel, moviesViewModel: moviesViewModel)
            //.disabled(true)
            //.foregroundColor(.gray)
          }
        }
      }
      .listStyle(.plain)
      .searchable(text: $searchText, prompt: "Buscar")
      Spacer()
      HStack {
          Button {
            genresListViewModel.refreshGenres()
            moviesViewModel.selectedGenres = genresListViewModel.selectedGenresNames
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

struct GenresRow: View {
  @Binding var genre: GenreData
  @ObservedObject var genresListViewModel: GenresListViewModel
  @ObservedObject var moviesViewModel: MoviesViewModel
  
  var body: some View {
    HStack {
      Text(genre.name)
      Spacer()
      if genre.selected {
        Image(systemName: "checkmark")
          .foregroundColor(.blue)
        
      }
      
    }
    .contentShape(Rectangle())
    .onTapGesture {
      genre.selected.toggle()
      moviesViewModel.selectedGenres = genresListViewModel.selectedGenresNames
      moviesViewModel.refreshMovies()
    }
  }
}
