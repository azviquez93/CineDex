import Alamofire
import CoreData
import Foundation

final class APIFetchHandler {
  static let shared = APIFetchHandler()
  
  func fetchAPIData(completion: @escaping () -> Void) {
    let url = "http://192.168.68.100:8000/api/v1/movies"
    let persistenceController = PersistenceController.shared
    
    AF.request(url, method: .get)
      .validate(statusCode: 200 ..< 300)
      .responseDecodable(of: [MovieInfo].self) { response in
        switch response.result {
        case .success(let movieDataArray):
          let group = DispatchGroup() // Create a dispatch group
          persistenceController.resetCoreData()
          //          for movie in movieDataArray {
          //            if let artworkURLString = movie.metadata.artwork {
          //              group.enter() // Enter the group before downloading artwork
          //              self.downloadArtwork(from: artworkURLString) { success in
          //                if success {
          //                } else {
          //                  print("Failed to download artwork for movie ID \(movie.id)")
          //                }
          //                group.leave() // Leave the group after downloading artwork
          //              }
          //            }
          //          }
          group.notify(queue: .main) {
            // This block is called when all tasks in the group have completed
            persistenceController.batchInsertMovies(movieDataArray) {
              print("All movies have been inserted into Core Data.")
              completion()
            }
          }
        case .failure(let error):
          // Handle the error here
          print("Error: \(error)")
          completion()
        }
      }
  }
  
  func refreshArtworks(completion: @escaping () -> Void) {
    let persistenceController = PersistenceController.shared
    let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
    
    // Execute the fetch request
    do {
      let movieDataArray = try persistenceController.container.viewContext.fetch(fetchRequest)
      // Use DispatchGroup to wait for all downloads to complete
      let group = DispatchGroup()
      
      for movie in movieDataArray {
        if let artworkURLString = movie.metadata?.artwork {
          group.enter() // Enter the group before downloading artwork
          self.downloadArtwork(from: artworkURLString) { success in
            if success {
              // Handle success, e.g., update UI or save artwork to Core Data
            } else {
              print("Failed to download artwork for movie ID \(movie.id)")
            }
            group.leave() // Leave the group after downloading artwork
          }
        }
      }
      
      // Notify when all downloads are complete
      group.notify(queue: .main) {
        completion()
      }
    } catch {
      // Handle fetch request error
      print("Failed to fetch movies: \(error)")
      completion()
    }
  }
  
  private func downloadArtwork(from urlString: String, completion: @escaping (Bool) -> Void) {
    guard let url = URL(string: "http://192.168.68.100:8000/uploads/movies/artworks/\(urlString)") else {
      completion(false)
      return
    }
    
    // Construct the destination file path
    let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let fileName = url.lastPathComponent
    let fileURL = documentsDirectory.appendingPathComponent(fileName)
    
    // Check if the file already exists at the destination path
    if FileManager.default.fileExists(atPath: fileURL.path) {
      completion(true)
      return
    }
    
    // If the file doesn't exist, proceed with the download
    AF.download(url).responseData { response in
      switch response.result {
      case .success(let data):
        do {
          try data.write(to: fileURL, options: .atomic)
          completion(true)
        } catch {
          print("Error saving image to disk: \(error)")
          completion(false)
        }
      case .failure(let error):
        // Handle the error here
        print("Error downloading artwork: \(error)")
        completion(false)
      }
    }
  }
}

struct MovieInfo: Codable {
  let id: Int64
  let createdAt: String
  let updatedAt: String
  let imdb: ImdbInfo?
  let rottentomatoes: RottentomatoesInfo?
  let metacriticId: String?
  let filmaffinityId: String?
  let letterboxdId: String?
  let contentRating: ContentRatingInfo?
  let studio: StudioInfo?
  let metadata: MetadataInfo
  let specification: SpecificationInfo
  let directors: [DirectorInfo]?
  let genres: [GenreInfo]?
  let stars: [StarInfo]?
  let writers: [WriterInfo]?
  let countries: [CountryInfo]?
  
  enum CodingKeys: String, CodingKey {
    case id
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case imdb
    case rottentomatoes
    case metacriticId = "metacritic_id"
    case filmaffinityId = "filmaffinity_id"
    case letterboxdId = "letterboxd_id"
    case studio
    case metadata
    case specification
    case directors
    case genres
    case stars
    case writers
    case contentRating = "content_rating"
    case countries
  }
}

struct StarInfo: Codable {
  let name: String
  
  enum CodingKeys: String, CodingKey {
    case name
  }
}

struct DirectorInfo: Codable {
  let name: String
  
  enum CodingKeys: String, CodingKey {
    case name
  }
}

struct WriterInfo: Codable {
  let name: String
  
  enum CodingKeys: String, CodingKey {
    case name
  }
}

struct GenreInfo: Codable {
  let name: String
  
  enum CodingKeys: String, CodingKey {
    case name
  }
}

struct CountryInfo: Codable {
  let name: String
  
  enum CodingKeys: String, CodingKey {
    case name
  }
}

struct ContentRatingInfo: Codable {
  let name: String
  
  enum CodingKeys: String, CodingKey {
    case name
  }
}

struct StudioInfo: Codable {
  let name: String
  
  enum CodingKeys: String, CodingKey {
    case name
  }
}

struct ImdbInfo: Codable {
  let siteId: String
  let siteRatingCount: Int64?
  let siteRatingValue: Double?
  
  enum CodingKeys: String, CodingKey {
    case siteId = "id"
    case siteRatingCount = "site_rating_count"
    case siteRatingValue = "site_rating_value"
  }
}

struct RottentomatoesInfo: Codable {
  let siteId: String
  let siteRatingCount: Int64?
  let siteRatingValue: Int16?
  let userRatingCount: Int64?
  let userRatingValue: Int16?
  
  enum CodingKeys: String, CodingKey {
    case siteId = "id"
    case siteRatingCount = "site_rating_count"
    case siteRatingValue = "site_rating_value"
    case userRatingCount = "user_rating_count"
    case userRatingValue = "user_rating_value"
  }
}

struct MetadataInfo: Codable {
  let id: Int64
  let alternativeTitle: String?
  let originalTitle: String
  let artwork: String?
  let summary: String?
  let duration: Int?
  let year: Int?
  let addedAt: Int64
  
  enum CodingKeys: String, CodingKey {
    case id
    case alternativeTitle = "alternative_title"
    case originalTitle = "original_title"
    case artwork
    case summary
    case duration
    case year
    case addedAt = "added_at"
  }
}

struct SpecificationInfo: Codable {
  let id: Int64
  let file: String
  let width: Int?
  let height: Int?
  let size: Int?
  let duration: Int?
  let bitrate: Int?
  let container: String?
  let videoCodec: String?
  let audioCodec: String?
  let framesPerSecond: Double?
  let audioChannels: Int?
  
  enum CodingKeys: String, CodingKey {
    case id
    case file
    case width
    case height
    case size
    case duration
    case bitrate
    case container
    case videoCodec = "video_codec"
    case audioCodec = "audio_codec"
    case framesPerSecond = "frames_per_second"
    case audioChannels = "audio_channels"
  }
}
