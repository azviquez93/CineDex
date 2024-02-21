import Alamofire
import Foundation

final class APIFetchHandler {
  
  static let shared = APIFetchHandler()
  
  func fetchAPIData(completion: @escaping () -> Void) {
    
    let url = "http://192.168.68.101:8000/api/v1/movies"
    let persistenceController = PersistenceController.shared
    
    AF.request(url, method: .get)
      .validate(statusCode:  200..<300)
      .responseDecodable(of: [MovieInfo].self) { response in
        switch response.result {
        case .success(let movieDataArray):
          persistenceController.resetCoreData()
          persistenceController.batchInsertMovies(movieDataArray) {
            // Completion handler of batchInsertMovies
            completion()
          }
        case .failure(let error):
          // Handle the error here
          print("Error: \(error)")
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
