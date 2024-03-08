//
//  CineDexApp.swift
//  CineDex
//
//  Created by Andrés Zamora on 20/2/24.
//

import SwiftUI
import Firebase

@main
struct CineDexApp: App {
  let persistenceController = PersistenceController.shared
  @ObservedObject var moviesViewModel = MoviesViewModel()
  @AppStorage("appearance") var appearance: Appearance = .automatic
  @AppStorage("moviesViewStyle") var viewStyle: MoviesViewStyle = .list
  
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      MainView(moviesViewModel: moviesViewModel)
        .preferredColorScheme(appearance.getColorScheme())
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
