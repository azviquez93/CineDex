//
//  SettingsView.swift
//  CineDex
//
//  Created by Andrés Zamora on 21/2/24.
//

import SwiftUI

struct SettingsView: View {
  @AppStorage("appearance") var appearance: Appearance = .automatic
  @AppStorage("moviesViewStyle") var moviesViewStyle: MoviesViewStyle = .list
  @ObservedObject var moviesViewModel: MoviesViewModel
  
  var body: some View {
    NavigationStack {
      List {
        Section(header: Text("Aspecto")) {
          Picker("Aspecto", selection: $appearance) {
            ForEach(Appearance.allCases) { appearance in
              Text(appearance.name).tag(appearance)
            }
          }
          .pickerStyle(.segmented)
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
