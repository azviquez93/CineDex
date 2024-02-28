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
            directorsListViewModel.refreshDirectors()
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
      moviesViewModel.refreshMovies()
    }
  }
}
