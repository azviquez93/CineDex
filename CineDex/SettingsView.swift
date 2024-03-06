//
//  SettingsView.swift
//  CineDex
//
//  Created by Andrés Zamora on 21/2/24.
//

import SwiftUI

struct SettingsView: View {
  @AppStorage("appearance") var appearance: Appearance = .automatic
  @AppStorage("rating") var rating: Rating = .imdb
  @AppStorage("moviesViewStyle") var moviesViewStyle: MoviesViewStyle = .list
  @ObservedObject var moviesViewModel: MoviesViewModel

  var body: some View {
    NavigationStack {
      List {
        Section(header: Text("General")) {
          Picker("Aspecto", selection: $appearance) {
            ForEach(Appearance.allCases) { appearance in
              Text(appearance.name).tag(appearance)
            }
          }
          .pickerStyle(.navigationLink)
          Picker("Calificación", selection: $rating) {
            ForEach(Rating.allCases, id: \.self) { rating in
              Text(rating.name).tag(rating)
                .lineLimit(1) // Limit to one line
                .truncationMode(.tail) // Truncate at the end
            }
          }
          .pickerStyle(.navigationLink)
          .onChange(of: self.rating) {
            // Perform action based on the new sortOption
            self.moviesViewModel.refreshMovies()
          }
        }
        Section {
          Button("Recargar películas") {
            refreshMovies()
          }
          Button("Recargar pósters") {
            refreshArtworks()
          }
        }
      }
      .navigationTitle("Ajustes")
      .listStyle(.grouped)
    }
  }

  private func refreshMovies() {
    APIFetchHandler.shared.fetchAPIData {
      FilterOptionsHandler.shared.refreshFilters()
      moviesViewModel.refreshMovies()
    }
  }

  private func refreshArtworks() {
    APIFetchHandler.shared.refreshArtworks {
      print("Descarga completa")
    }
  }
}
