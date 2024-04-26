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
  
  func signUp() async throws -> Bool {
    guard !email.isEmpty, !password.isEmpty else {
      print("No email or password found")
      return false
    }
    
    do {
      _ = try await AuthenticationManager.shared.register(email: email, password: password)
      print("User registered successful")
      // Perform any additional actions after sign out
      return true
    } catch {
      print("Registration failed: \(error)")
      // Handle the error, e.g., show an alert
      return false
    }
  }
  
  func signIn() async throws -> Bool {
    guard !email.isEmpty, !password.isEmpty else {
      print("No email or password found")
      return false
    }
    
    do {
      _ = try await AuthenticationManager.shared.signIn(email: email, password: password)
      print("User logged in successful")
      // Perform any additional actions after sign out
      return true
    } catch {
      print("Login failed: \(error)")
      // Handle the error, e.g., show an alert
      return false
    }
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
      
      Button(action: {
        Task {
          do {
            showSignInView = try await viewModel.signIn() == false
          } catch {
            print(error)
          }
        }
      }
      ) {
        LogginButtonContent()
      }
      Spacer()
    }
    .padding()
    .navigationTitle("Iniciar sesión con correo")
  }
}

struct LogginButtonContent: View {
  var body: some View {
    Text("Iniciar sesión")
      .font(.headline)
      .foregroundColor(.white)
      .frame(height: 55)
      .frame(maxWidth: .infinity)
      .background(Color.blue)
      .cornerRadius(10)
  }
}
