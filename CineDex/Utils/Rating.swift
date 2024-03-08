//
//  Rating.swift
//  CineDex
//
//  Created by Andrés Zamora on 21/2/24.
//

import SwiftUI

enum Rating: Int, CaseIterable, Identifiable {
  case imdb, rottentomatoesSite, rottentomatoesUsers, metacriticSite, metacriticUsers, filmaffinity, letterboxd

  var id: Int { rawValue }

  var name: String {
    switch self {
    case .imdb: return "IMDb"
    case .rottentomatoesSite: return "Rotten Tomatoes (Críticos)"
    case .rottentomatoesUsers: return "Rotten Tomatoes (Audiencia)"
    case .metacriticSite: return "Metacritic (Críticos)"
    case .metacriticUsers: return "Metacritic (Audiencia)"
    case .filmaffinity: return "Filmaffinity"
    case .letterboxd: return "Letterboxd"
    }
  }
}
