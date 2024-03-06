//
//  Appearance.swift
//  CineDex
//
//  Created by Andrés Zamora on 21/2/24.
//

import SwiftUI

enum Appearance: Int, CaseIterable, Identifiable {
  case light, dark, automatic

  var id: Int { rawValue }

  var name: String {
    switch self {
    case .light: return "Claro"
    case .dark: return "Oscuro"
    case .automatic: return "Automático"
    }
  }

  func getColorScheme() -> ColorScheme? {
    switch self {
    case .automatic: return nil
    case .light: return .light
    case .dark: return .dark
    }
  }
}
