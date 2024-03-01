import SwiftUI

struct StarsListView: View {
  @State private var searchText: String = ""
  @ObservedObject var starsListViewModel: StarsListViewModel
  @ObservedObject var moviesViewModel: MoviesViewModel
  
  var body: some View {
    VStack {
      List {
        ForEach($starsListViewModel.stars) { $star in
          if searchText.isEmpty || (star.name.localizedCaseInsensitiveContains(searchText)) {
            StarsRow(star: $star, starsListViewModel: starsListViewModel, moviesViewModel: moviesViewModel)
          }
        }
      }
      .listStyle(.plain)
      .searchable(text: $searchText, prompt: "Buscar")
      Spacer()
      HStack {
          Button {
            starsListViewModel.refreshStars(keepSelection: false, reset: false)
            FilterOptionsHandler.shared.genresListViewModel.refreshGenres(keepSelection: true, reset: false)
            FilterOptionsHandler.shared.starsListViewModel.refreshStars(keepSelection: true, reset: false)
            moviesViewModel.refreshMovies()
          } label: {
              Text("Restablecer")
              .foregroundColor(.red)
          }
          .padding()
      }
    }
    .navigationTitle("Star")
    .navigationBarTitleDisplayMode(.inline)
  }
}

struct StarsRow: View {
  @Binding var star: StarData
  @ObservedObject var starsListViewModel: StarsListViewModel
  @ObservedObject var moviesViewModel: MoviesViewModel
  
  var body: some View {
    HStack {
      Text(star.name)
      Spacer()
      if star.selected {
        Image(systemName: "checkmark")
          .foregroundColor(.blue)
        
      }
      
    }
    .contentShape(Rectangle())
    .onTapGesture {
      star.selected.toggle()
      FilterOptionsHandler.shared.genresListViewModel.refreshGenres(keepSelection: true, reset: false)
      FilterOptionsHandler.shared.directorsListViewModel.refreshDirectors(keepSelection: true, reset: false)
      moviesViewModel.refreshMovies()
    }
  }
}
