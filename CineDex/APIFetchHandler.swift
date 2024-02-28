import Alamofire
import Foundation

final class APIFetchHandler {
  
  static let shared = APIFetchHandler()
  
  func fetchAPIData(completion: @escaping () -> Void) {
    
    let url = "http://192.168.68.104:8000/api/v1/movies"
    let persistenceController = PersistenceController.shared
    
    AF.request(url, method: .get)
      .validate(statusCode:  200..<300)
      .responseDecodable(of: [MovieInfo].self) { response in
        switch response.result {
        case .success(let movieDataArray):
          let group = DispatchGroup() // Create a dispatch group
          persistenceController.resetCoreData()
          for movie in movieDataArray {
            if let artworkURLString = movie.metadata.artwork {
              group.enter() // Enter the group before downloading artwork
              self.downloadArtwork(from: artworkURLString) { success in
                if success {
                } else {
                  print("Failed to download artwork for movie ID \(movie.id)")
                }
                group.leave() // Leave the group after downloading artwork
              }
            }
          }
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
  
  private func downloadArtwork(from urlString: String, completion: @escaping (Bool) -> Void) {
    guard let url = URL(string: "http://192.168.68.104:8000/uploads/movies/artworks/\(urlString)") else {
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
  let imdbId: String?
  let rottentomatoesId: String?
  let metacriticId: String?
  let filmaffinityId: String?
  let letterboxdId: String?
  let contentRatingId: Int?
  let studioId: Int?
  let metadata: MetadataInfo
  let specification: SpecificationInfo
  let directors: [DirectorInfo]
  let genres: [GenreInfo]
  
  enum CodingKeys: String, CodingKey {
    case id
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case imdbId = "imdb_id"
    case rottentomatoesId = "rottentomatoes_id"
    case metacriticId = "metacritic_id"
    case filmaffinityId = "filmaffinity_id"
    case letterboxdId = "letterboxd_id"
    case contentRatingId = "content_rating_id"
    case studioId = "studio_id"
    case metadata
    case specification
    case directors
    case genres
  }
}

struct DirectorInfo: Codable {
  let id: Int64
  let createdAt: String
  let updatedAt: String
  let person: PersonInfo
  
  enum CodingKeys: String, CodingKey {
    case id
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case person
  }
}

struct GenreInfo: Codable {
  let id: Int64
  let createdAt: String
  let updatedAt: String
  let name: String
  
  enum CodingKeys: String, CodingKey {
    case id
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case name
  }
}

struct PersonInfo: Codable {
  let id: Int64
  let createdAt: String
  let updatedAt: String
  let name: String
  
  enum CodingKeys: String, CodingKey {
    case id
    case createdAt = "created_at"
    case updatedAt = "updated_at"
    case name
  }
}

struct MetadataInfo: Codable {
  let id: Int64
  let createdAt: String
  let updatedAt: String
  let alternativeTitle: String?
  let originalTitle: String
  let artwork: String?
  let summary: String?
  let duration: Int?
  let year: Int?
  let addedAt: Int64
  
  enum CodingKeys: String, CodingKey {
    case id
    case createdAt = "created_at"
    case updatedAt = "updated_at"
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
  let createdAt: String
  let updatedAt: String
  let file: String
  let width: Int?
  let height: Int?
  let size: Int?
  let duration: Int?
  let bitrate: Int?
  let container: String?
  let videoCodec: String?
  let audioCodec: String?
  let framesPerSecond: String?
  let audioChannels: Int?
  
  enum CodingKeys: String, CodingKey {
    case id
    case createdAt = "created_at"
    case updatedAt = "updated_at"
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
