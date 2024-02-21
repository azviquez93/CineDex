//
//  MoviesView.swift
//  CineDex
//
//  Created by Andrés Zamora on 20/2/24.
//

import SwiftUI

struct MoviesView: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  @ObservedObject var moviesViewModel = MoviesViewModel()
  
  var body: some View {
    NavigationStack {
      List {
        ForEach(moviesViewModel.movies) { movie in
          NavigationLink(destination: MovieDetailView(movie: movie)) {
            VStack(alignment: .leading) {
              Text(movie.metadata?.originalTitle ?? "Unknown Title")
                .font(.headline)
              Text("\(moviesViewModel.formattedYear(year: movie.metadata?.year))")
                .foregroundColor(.secondary)
            }
          }
        }
      }
      .listStyle(.plain)
      .toolbar {
        ToolbarItem {
          Button(action: refreshMovies) {
            Label("Refresh", systemImage: "arrow.triangle.2.circlepath")
          }
        }
      }
    }
    .onAppear {
      moviesViewModel.refreshMovies()
    }
  }
  
  private func refreshMovies() {
    APIFetchHandler.shared.fetchAPIData {
      // This closure is the completion handler, you can add any logic that should
      // be executed after the fetchAPIData is completed.
      moviesViewModel.refreshMovies()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    MoviesView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
  }
}
