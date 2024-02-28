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
  
  var body: some View {
    switch moviesViewStyle {
    case.list:
      MoviesListView(moviesViewModel: moviesViewModel)
    case.grid:
      MoviesGridView(moviesViewModel: moviesViewModel)
    }
  }
}
