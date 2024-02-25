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
          VStack(alignment: .leading) {
            Picker("", selection: $appearance) {
              ForEach(Appearance.allCases) { appearance in
                Text(appearance.name).tag(appearance)
              }          }
            .pickerStyle(SegmentedPickerStyle())
          }
        }
        
        Section {
          Button("Recargar películas") {
            refreshMovies()
          }
        }
      }
      .navigationTitle("Ajustes")
    }
  }
  
  private func refreshMovies() {
    APIFetchHandler.shared.fetchAPIData {
      moviesViewModel.refreshMovies()
    }
  }
  
}
