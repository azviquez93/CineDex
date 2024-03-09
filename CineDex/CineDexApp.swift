//
//  CineDexApp.swift
//  CineDex
//
//  Created by Andrés Zamora on 20/2/24.
//

import Firebase
import SwiftUI

@main
struct CineDexApp: App {

  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      
      RootView()
      
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
  {
    FirebaseApp.configure()
    return true
  }
}
