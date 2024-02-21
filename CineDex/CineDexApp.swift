//
//  CineDexApp.swift
//  CineDex
//
//  Created by Andrés Zamora on 20/2/24.
//

import SwiftUI

@main
struct CineDexApp: App {
  let persistenceController = PersistenceController.shared
  
  var body: some Scene {
    WindowGroup {
      MoviesView()
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
