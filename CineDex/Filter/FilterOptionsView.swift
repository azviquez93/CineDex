//
//  FilterOptionsView.swift
//  CineDex
//
//  Created by Andrés Zamora on 21/2/24.
//

import SwiftUI

struct FilterOptionsView: View {
  
  @ObservedObject var genresListViewModel = FilterOptionsHandler.shared.genresListViewModel
  @ObservedObject var directorsListViewModel = FilterOptionsHandler.shared.directorsListViewModel
  @ObservedObject var moviesViewModel: MoviesViewModel
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    NavigationStack {
      VStack {
        List {
          NavigationLink(destination: GenresListView(genresListViewModel: genresListViewModel, moviesViewModel: moviesViewModel)) {
            FilterOptionView(label: "Género", selectedOption: genresListViewModel.selectedLabel)
          }
          NavigationLink(destination: DirectorsListView(directorsListViewModel: directorsListViewModel, moviesViewModel: moviesViewModel)) {
            FilterOptionView(label: "Director", selectedOption: directorsListViewModel.selectedLabel)
          }
        }
        .listStyle(.plain)
        
        Spacer() // Spacer to push the button to the bottom
        
        HStack {
            Button {
              genresListViewModel.refreshGenres()
              directorsListViewModel.refreshDirectors()
              moviesViewModel.refreshMovies()
            } label: {
                Text("Restablecer todos")
                .foregroundColor(.red)
            }
            .padding()
        }
      }
      .navigationTitle("Filtros")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            dismiss()
          } label: {
            Text("Listo")
          }
          .foregroundColor(.blue)
        }
      }
    }
  }
}
