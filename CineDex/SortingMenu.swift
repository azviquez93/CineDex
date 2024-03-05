import SwiftUI

enum SortOption: Int, CaseIterable, Identifiable {
  case year = 0, title
  
  var id: Int { self.rawValue }
  var label: String {
    switch self {
    case .year: return "Año"
    case .title: return "Título"
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
  @State private var sortOption: SortOption = .year
  @State private var sortMode: SortMode = .ascending
  
  var body: some View {
    Menu {
      Picker("Sorting options", selection: $sortOption) {
        ForEach(SortOption.allCases) { option in
          Text(option.label).tag(option)
        }
      }
      .onChange(of: sortOption) {
        // Perform action based on the new sortOption
        print("Sort option changed to: \(sortOption.label)")
      }
      Divider()
      Picker("Sorting mode", selection: $sortMode) {
        ForEach(SortMode.allCases) { mode in
          Text(mode.label).tag(mode)
        }
      }
      .onChange(of: sortMode) {
        // Perform action based on the new sortOption
        print("Sort option changed to: \(sortMode.label)")
      }
    } label: {
      Button(action: {}) {
        Text("Ordenar por")
        Text(sortOption.label)
        Image(systemName: "arrow.up.arrow.down")
      }
    }
  }
}
