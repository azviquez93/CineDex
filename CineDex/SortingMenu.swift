import SwiftUI

enum SortOption: Int, CaseIterable, Identifiable {
  case year = 0, title, created, imdbRating

  var id: Int { self.rawValue }
  var label: String {
    switch self {
    case .year: return "Año"
    case .created: return "Fecha en que se agregó"
    case .title: return "Título"
    case .imdbRating: return "Calificación IMDb"
    }
  }
}

enum SortMode: Int, CaseIterable, Identifiable {
  case ascending = 0, descending

  var id: Int { self.rawValue }
  var label: String {
    switch self {
    case .ascending: return "Ascendente"
    case .descending: return "Descendente"
    }
  }
}

struct SortingMenu: View {
  @ObservedObject var moviesViewModel: MoviesViewModel

  var body: some View {
    Menu {
      Picker("Sorting options", selection: self.$moviesViewModel.sortOption) {
        ForEach(SortOption.allCases) { option in
          Text(option.label).tag(option)
        }
      }
      .onChange(of: self.moviesViewModel.sortOption) {
        // Perform action based on the new sortOption
        self.moviesViewModel.updateSortDescriptor()
      }
      Divider()
      Picker("Sorting mode", selection: self.$moviesViewModel.sortMode) {
        ForEach(SortMode.allCases) { mode in
          Text(mode.label).tag(mode)
        }
      }
      .onChange(of: self.moviesViewModel.sortMode) {
        // Perform action based on the new sortOption
        self.moviesViewModel.updateSortDescriptor()
      }
    } label: {
      Button(action: {}) {
        Text("Ordenar por")
        Text(self.moviesViewModel.sortOption.label)
        Image(systemName: "arrow.up.arrow.down")
      }
    }
  }
}
