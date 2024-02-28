//
//  MainView.swift
//  CineDex
//
//  Created by Andrés Zamora on 21/2/24.
//

import SwiftUI

struct MainView: View {
  
  @ObservedObject var moviesViewModel: MoviesViewModel
  
  var body: some View {
    TabView {
      MoviesView(moviesViewModel: moviesViewModel)
        .tabItem {
          Label("Películas", systemImage: "popcorn")
        }
      
      SettingsView(moviesViewModel: moviesViewModel)
        .tabItem {
          Label("Ajustes", systemImage: "gear")
        }
    }.onAppear {
      moviesViewModel.refreshMovies()
      FilterOptionsHandler.shared.refreshFilters()
    }
  }
}
