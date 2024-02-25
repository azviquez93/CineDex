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
  @ObservedObject var moviesViewModel = MoviesViewModel()
  @ObservedObject var genresListViewModel = GenresListViewModel()
  @AppStorage("appearance") var appearance: Appearance = .automatic
  @AppStorage("moviesViewStyle") var viewStyle: MoviesViewStyle = .list
  
  var body: some Scene {
    WindowGroup {
      MainView(moviesViewModel: moviesViewModel, genresListViewModel: genresListViewModel)
        .preferredColorScheme(appearance.getColorScheme())
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}
