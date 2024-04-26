//
//  SettingsView.swift
//  CineDex
//
//  Created by Andrés Zamora on 21/2/24.
//

import SwiftUI

@MainActor
final class SettingViewModel: ObservableObject {
  func signOut() throws {
    Task {
      do {
        try await AuthenticationManager.shared.signOut()
        print("Sign out successful")
        // Perform any additional actions after sign out
      } catch {
        print("Sign out failed: \(error)")
        // Handle the error, e.g., show an alert
      }
    }
  }
}

struct SettingsView: View {
  @Binding var showSignInView: Bool
  @AppStorage("appearance") var appearance: Appearance = .automatic
  @AppStorage("rating") var rating: Rating = .imdb
  @AppStorage("moviesViewStyle") var moviesViewStyle: MoviesViewStyle = .list
  @ObservedObject var moviesViewModel: MoviesViewModel
  
  @StateObject private var viewModel = SettingViewModel()
  
  var body: some View {
    NavigationStack {
      List {
        Section(header: Text("General")) {
          Picker("Aspecto", selection: $appearance) {
            ForEach(Appearance.allCases) { appearance in
              Text(appearance.name).tag(appearance)
            }
          }
          .pickerStyle(.navigationLink)
          Picker("Calificación", selection: $rating) {
            ForEach(Rating.allCases, id: \.self) { rating in
              Text(rating.name).tag(rating)
                .lineLimit(1) // Limit to one line
                .truncationMode(.tail) // Truncate at the end
            }
          }
          .pickerStyle(.navigationLink)
          .onChange(of: self.rating) {
            // Perform action based on the new sortOption
            self.moviesViewModel.refreshMovies()
          }
        }
        Section("Datos") {
          Button("Recargar películas") {
            refreshMovies()
          }
          Button("Recargar pósters") {
            refreshArtworks()
          }
        }
        
        Section {
          Button("Cerrar sesión") {
            Task {
              do {
                try viewModel.signOut()
                showSignInView = true
              } catch {
                print(error)
              }
            }
          }
          .frame(maxWidth: .infinity, alignment: .center)
          .foregroundColor(.red)
        }
      }
      .navigationTitle("Ajustes")
      .listStyle(.grouped)
    }
  }
  
  private func refreshMovies() {
    APIFetchHandler.shared.fetchAPIData {
      FilterOptionsHandler.shared.refreshFilters()
      moviesViewModel.refreshMovies()
    }
  }
  
  private func refreshArtworks() {
    APIFetchHandler.shared.refreshArtworks {
      print("Descarga completa")
    }
  }
}
