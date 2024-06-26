//
//  MainView.swift
//  CineDex
//
//  Created by Andrés Zamora on 21/2/24.
//

import SwiftUI

struct MainView: View {
  @Binding var showSignInView: Bool
  @ObservedObject var moviesViewModel: MoviesViewModel

  var body: some View {
    TabView {
      MoviesView(moviesViewModel: moviesViewModel)
        .tabItem {
          Label("Películas", systemImage: "popcorn")
        }

      SettingsView(showSignInView: $showSignInView, moviesViewModel: moviesViewModel)
        .tabItem {
          Label("Ajustes", systemImage: "gear")
        }
    }.onAppear {
      FilterOptionsHandler.shared.refreshFilters()
      moviesViewModel.refreshMovies()
    }
  }
}
