//
//  MoviesGridView.swift
//  CineDex
//
//  Created by Andrés Zamora on 21/2/24.
//

import SwiftUI

struct MoviesGridView: View {
  @ObservedObject var moviesViewModel: MoviesViewModel
  @State private var showFilters: Bool = false
  @AppStorage("moviesViewStyle") var moviesViewStyle: MoviesViewStyle = .grid
  
  let layout = [
    GridItem(.adaptive(minimum: 80, maximum: 120)),
  ]
  
  func retrieveImagePath(forArtwork artworkName: String) -> String? {
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileURL = documentsDirectory.appendingPathComponent(artworkName)
    if FileManager.default.fileExists(atPath: fileURL.path) {
      return fileURL.path
    }
    return nil
  }
  
  var body: some View {
    NavigationStack {
      ScrollView {
        LazyVGrid(columns: layout, spacing: 20) {
          ForEach(moviesViewModel.movies, id: \.self) { movie in
            NavigationLink(destination: MovieDetailView(movie: movie)) {
              VStack {
                // Assuming you have a function to retrieve the file path for the image
                if let artworkPath = retrieveImagePath(forArtwork: movie.metadata?.artwork ?? "") {
                  // Create a URL from the file path
                  let fileURL = URL(fileURLWithPath: artworkPath)
                  // Use AsyncImage to load the image from the file URL
                  AsyncImage(url: fileURL) { image in
                    image.resizable()
                  } placeholder: {
                    ProgressView()
                  }
                  .frame(width: 80, height: 120)
                  .cornerRadius(10)
                }
                Text(movie.metadata?.originalTitle ?? "")
                  .font(.subheadline)
                  .foregroundColor(.primary)
                  .lineLimit(1) // Limit to one line
                  .truncationMode(.tail) // Truncate at the end
              }
            }
          }
        }
      }
      .navigationTitle("Películas (\(NumberFormatter().string(from: moviesViewModel.movies.count as NSNumber)!))")
      .searchable(text: $moviesViewModel.searchText, prompt: "Buscar")
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
              moviesViewStyle = .list
            }) {
              Label("Ver como lista", systemImage: "list.bullet")
            }
            
            Divider()
            
            SortingMenu(moviesViewModel: moviesViewModel)
            
          } label: {
            Image(systemName: "ellipsis.circle")
          }
        }
      }
    }
    .sheet(isPresented: $showFilters, content: {
      FilterOptionsView(moviesViewModel: moviesViewModel)
    })
  }
}
