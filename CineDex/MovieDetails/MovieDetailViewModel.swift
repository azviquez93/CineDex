import SwiftUI

class MovieDetailViewModel: ObservableObject {
  @Published var movie: Movie
  
  init(movie: Movie) {
    self.movie = movie
  }
  
  var formattedYear: String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .none
    return numberFormatter.string(from: NSNumber(value: movie.metadata?.year ?? 0)) ?? ""
  }
  
  func formattedRating(for value: Double?) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.minimumFractionDigits = 1
    numberFormatter.maximumFractionDigits = 1
    numberFormatter.decimalSeparator = "."
    return numberFormatter.string(from: NSNumber(value: value ?? 0)) ?? ""
  }
  
}
