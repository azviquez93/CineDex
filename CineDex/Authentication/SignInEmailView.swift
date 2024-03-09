//
//  SignInEmailView.swift
//  CineDex
//
//  Created by Andrés Zamora on 8/3/24.
//

import SwiftUI

@MainActor
final class SignInEmailViewModel: ObservableObject {
  @Published var email = ""
  @Published var password = ""
  
  func signUp() async throws {
    guard !email.isEmpty, !password.isEmpty else {
      print("No email or password found")
      return
    }
    try await AuthenticationManager.shared.createUser(email: email, password: password)
  }
  
  func signIn() async throws {
    guard !email.isEmpty, !password.isEmpty else {
      print("No email or password found")
      return
    }
    try await AuthenticationManager.shared.signInUser(email: email, password: password)
  }
}

struct SignInEmailView: View {
  @Binding var showSignInView: Bool
  @StateObject private var viewModel = SignInEmailViewModel()
  
  var body: some View {
    VStack {
      TextField("Correo...", text: $viewModel.email)
        .keyboardType(.emailAddress)
        .autocapitalization(.none)
        .padding()
        .background(Color.gray.opacity(0.4))
        .cornerRadius(10)
      
      SecureField("Contraseña...", text: $viewModel.password)
        .padding()
        .background(Color.gray.opacity(0.4))
        .cornerRadius(10)
      
      Button {
        Task {
          do {
            try await viewModel.signUp()
            showSignInView = false
            return
          }
          catch {
            print(error)
          }
          
          do {
            try await viewModel.signIn()
            showSignInView = false
            return
          }
          catch {
            print(error)
          }
        }
      } label: {
        Text("Iniciar sesión")
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
    .navigationTitle("Iniciar sesión con correo")
  }
}
