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
  
  var body: some View {
    switch moviesViewStyle {
    case.list:
      MoviesListView(genresListViewModel: genresListViewModel, moviesViewModel: moviesViewModel)
    case.grid:
      MoviesGridView(genresListViewModel: genresListViewModel, moviesViewModel: moviesViewModel)
    }
  }
}
