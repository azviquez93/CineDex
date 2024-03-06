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
  @ObservedObject var starsListViewModel = FilterOptionsHandler.shared.starsListViewModel
  @ObservedObject var writersListViewModel = FilterOptionsHandler.shared.writersListViewModel
  @ObservedObject var contentRatingsListViewModel = FilterOptionsHandler.shared.contentRatingsListViewModel
  @ObservedObject var studiosListViewModel = FilterOptionsHandler.shared.studiosListViewModel
  @ObservedObject var countriesListViewModel = FilterOptionsHandler.shared.countriesListViewModel
  @ObservedObject var moviesViewModel: MoviesViewModel
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    NavigationStack {
      VStack {
        List {
          NavigationLink(destination: GenresListView(genresListViewModel: genresListViewModel, moviesViewModel: moviesViewModel)) {
            FilterOptionView(label: "Géneros", selectedOption: genresListViewModel.selectedLabel)
          }
          NavigationLink(destination: DirectorsListView(directorsListViewModel: directorsListViewModel, moviesViewModel: moviesViewModel)) {
            FilterOptionView(label: "Directores", selectedOption: directorsListViewModel.selectedLabel)
          }
          NavigationLink(destination: StarsListView(starsListViewModel: starsListViewModel, moviesViewModel: moviesViewModel)) {
            FilterOptionView(label: "Reparto", selectedOption: starsListViewModel.selectedLabel)
          }
          NavigationLink(destination: WritersListView(writersListViewModel: writersListViewModel, moviesViewModel: moviesViewModel)) {
            FilterOptionView(label: "Guionistas", selectedOption: writersListViewModel.selectedLabel)
          }
          NavigationLink(destination: ContentRatingsListView(contentRatingsListViewModel: contentRatingsListViewModel, moviesViewModel: moviesViewModel)) {
            FilterOptionView(label: "Clasificaciones", selectedOption: contentRatingsListViewModel.selectedLabel)
          }
          NavigationLink(destination: StudiosListView(studiosListViewModel: studiosListViewModel, moviesViewModel: moviesViewModel)) {
            FilterOptionView(label: "Estudios", selectedOption: studiosListViewModel.selectedLabel)
          }
          NavigationLink(destination: CountriesListView(countriesListViewModel: countriesListViewModel, moviesViewModel: moviesViewModel)) {
            FilterOptionView(label: "Países", selectedOption: countriesListViewModel.selectedLabel)
          }
        }
        .listStyle(.plain)
        
        Spacer() // Spacer to push the button to the bottom
        
        HStack {
          Button {
            FilterOptionsHandler.shared.refreshFilters()
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
