//
//  MoviesView.swift
//  CineDex
//
//  Created by Andrés Zamora on 20/2/24.
//

import SwiftUI

struct MoviesView: View {
  @AppStorage("moviesViewStyle") var moviesViewStyle: MoviesViewStyle = .list
  @ObservedObject var moviesViewModel: MoviesViewModel
  @ObservedObject var genresListViewModel: GenresListViewModel
  @ObservedObject var directorsListViewModel: DirectorsListViewModel
  
  var body: some View {
    switch moviesViewStyle {
    case.list:
      MoviesListView(genresListViewModel: genresListViewModel, directorsListViewModel: directorsListViewModel, moviesViewModel: moviesViewModel)
    case.grid:
      MoviesGridView(directorsListViewModel: directorsListViewModel, genresListViewModel: genresListViewModel, moviesViewModel: moviesViewModel)
    }
  }
}
