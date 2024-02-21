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
}
