//
//  FilterOptionView.swift
//  CineDex
//
//  Created by Andrés Zamora on 21/2/24.
//

import SwiftUI

struct FilterOptionView: View {
  var label: String
  var selectedOption: String
  
  @ObservedObject var genresListViewModel = GenresListViewModel()
  
  var body: some View {
    VStack(alignment: .leading) {
      Text(label)
        .foregroundColor(.primary)
      Text(selectedOption)
        .font(.subheadline)
        .foregroundColor(.gray)
    }
  }
}

#Preview {
  FilterOptionView(label: "Test", selectedOption: "Test")
}
