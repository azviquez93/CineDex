//
//  MoviesListView.swift
//  CineDex
//
//  Created by Andrés Zamora on 21/2/24.
//

import SwiftUI

struct MoviesListView: View {
  
  @ObservedObject var moviesViewModel: MoviesViewModel
  @State private var selectedMovieId: Movie.ID?
  @State private var showFilters: Bool = false
  @AppStorage("moviesViewStyle") var moviesViewStyle: MoviesViewStyle = .list  
  
  func retrieveImagePath(forArtwork artworkName: String) -> String? {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsDirectory.appendingPathComponent(artworkName)
    
    // Check if the file exists at the given path
    if FileManager.default.fileExists(atPath: fileURL.path) {
      return fileURL.path
    }
    
    return nil
  }
  
  var body: some View {
    NavigationSplitView {
      List (moviesViewModel.movies, selection: $selectedMovieId) { movie in
        HStack {
          if let artworkPath = retrieveImagePath(forArtwork: movie.metadata?.artwork ?? "") {
            // Create a URL from the file path
            let fileURL = URL(fileURLWithPath: artworkPath)
            // Use AsyncImage to load the image from the file URL
            AsyncImage(url: fileURL) { image in
              image.resizable()
            } placeholder: {
              ProgressView()
            }
            .frame(width:  50, height:  70)
            .cornerRadius(10)
            
          }
          else {
            Image(systemName: "photo")
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(width: 50, height: 70) // Adjust size as needed
              .foregroundColor(.gray)
          }
          VStack(alignment: .leading) {
            Text(movie.metadata?.originalTitle ?? "Unknown Title")
              .font(.headline)
            Text("\(moviesViewModel.formattedYear(year: movie.metadata?.year))")
              .foregroundColor(.secondary)
          }
        }
      }
      .searchable(text: $moviesViewModel.searchText, prompt: "Buscar")
      .navigationTitle("Películas")
      .listStyle(.plain)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button(action: {
            showFilters.toggle()
          }) {
            Image(systemName: "line.3.horizontal.decrease.circle")
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu {
            Button(action: {
              moviesViewStyle = .grid
            }) {
              Label("Ver como galería", systemImage: "square.grid.2x2")
            }
            
            Divider()
            
            SortingMenu()
            
          } label: {
            Image(systemName: "ellipsis.circle")
          }
        }
        
      }
    } detail: {
      if let selectedMovieId = selectedMovieId {
        MovieDetailView(movie: moviesViewModel.movies.first { $0.id == selectedMovieId }!)
      } else {
        Text("Seleccione una película")
      }
    }
    .sheet(isPresented: $showFilters, content: {
      FilterOptionsView(moviesViewModel: moviesViewModel)
    })
  }
  
}
