//
//  MoviesViewStyle.swift
//  CineDex
//
//  Created by Andrés Zamora on 21/2/24.
//

import SwiftUI

enum MoviesViewStyle: Int, CaseIterable, Identifiable {
  case list, grid

  var id: Int { rawValue }

  var name: String {
    switch self {
    case .list: return "Lista"
    case .grid: return "Cuadrícula"
    }
  }
}
