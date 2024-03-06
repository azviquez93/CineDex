//
//  Rating.swift
//  CineDex
//
//  Created by Andrés Zamora on 21/2/24.
//

import SwiftUI

enum Rating: Int, CaseIterable, Identifiable {
  case imdb, rottentomatoesSite, rottentomatoesUsers

  var id: Int { rawValue }

  var name: String {
    switch self {
    case .imdb: return "IMDb"
    case .rottentomatoesSite: return "Rotten Tomatoes (Críticos)"
    case .rottentomatoesUsers: return "Rotten Tomatoes (Audiencia)"
    }
  }
}
