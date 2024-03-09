//
//  AuthenticationView.swift
//  CineDex
//
//  Created by Andrés Zamora on 8/3/24.
//

import SwiftUI

struct AuthenticationView: View {
  
  @Binding var showSignInView: Bool
  
  var body: some View {
    VStack {
      NavigationLink {
        SignInEmailView(showSignInView: $showSignInView)
      }
      label: {
        Text("Iniciar sesión con correo")
          .font(.headline)
          .foregroundColor(.white)
          .frame(height: 55)
          .frame(maxWidth: .infinity)
          .background(Color.blue)
          .cornerRadius(10)
      }
      Spacer()
    }
    .padding()
    .navigationTitle("Iniciar sesión")
  }
}
