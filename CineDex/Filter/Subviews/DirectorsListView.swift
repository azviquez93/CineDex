//
//  DirectorsListView.swift
//  CineDex
//
//  Created by Andrés Zamora on 22/2/24.
//

import SwiftUI

struct DirectorsListView: View {
  @State private var searchText: String = ""
  @Environment(\.managedObjectContext) private var viewContext
  @FetchRequest(entity: Director.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Director.person!.name, ascending: true)]) var directors: FetchedResults<Director>
  
  var body: some View {
    List {
      ForEach(directors) { director in
        if searchText.isEmpty || (director.person?.name?.localizedCaseInsensitiveContains(searchText) ?? false) {
          Text(director.person?.name ?? "Unknown Director")
        }
      }
    }
    .searchable(text: $searchText, prompt: "Buscar")
    .navigationTitle("Director")
    .navigationBarTitleDisplayMode(.inline)
  }
}
