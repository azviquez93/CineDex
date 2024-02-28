//
//  MainView.swift
//  CineDex
//
//  Created by Andrés Zamora on 21/2/24.
//

import SwiftUI

struct MainView: View {
  
  @ObservedObject var moviesViewModel: MoviesViewModel
  @ObservedObject var genresListViewModel: GenresListViewModel
  @ObservedObject var directorsListViewModel: DirectorsListViewModel
  
  var body: some View {
    TabView {
      MoviesView(moviesViewModel: moviesViewModel, genresListViewModel: genresListViewModel, directorsListViewModel: directorsListViewModel)
        .tabItem {
          Label("Películas", systemImage: "popcorn")
        }
      
      SettingsView(moviesViewModel: moviesViewModel)
        .tabItem {
          Label("Ajustes", systemImage: "gear")
        }
    }.onAppear {
      moviesViewModel.refreshMovies()
      genresListViewModel.refreshGenres()
      directorsListViewModel.refreshDirectors()
    }
  }
}
