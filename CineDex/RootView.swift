//
//  RootView.swift
//  CineDex
//
//  Created by Andrés Zamora on 8/3/24.
//

import SwiftUI

struct RootView: View {
  
  let persistenceController = PersistenceController.shared
  @AppStorage("appearance") var appearance: Appearance = .automatic
  @AppStorage("moviesViewStyle") var viewStyle: MoviesViewStyle = .list
  
  @State private var showSignInView: Bool = false
  @ObservedObject var moviesViewModel = MoviesViewModel()
  
  var body: some View {
    ZStack {
      MainView(showSignInView: $showSignInView, moviesViewModel: moviesViewModel)
        .preferredColorScheme(appearance.getColorScheme())
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
    .onAppear {
      let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
      self.showSignInView = authUser == nil
    }
    .fullScreenCover(isPresented: $showSignInView) {
      NavigationStack {
        AuthenticationView(showSignInView: $showSignInView)
      }
    }
  }
}

#Preview {
  RootView()
}
