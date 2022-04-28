import Foundation

struct BaseClientResponseModel(
    @SerializedName("data")
    val data: Any?,
    @SerializedName("error_code")
    var errorCode: Int = 0,
    @SerializedName("message")
    var message: String = "")


struct Film: Decodable {
  let id: Int
  let title: String
  let openingCrawl: String
  let director: String
  let producer: String
  let releaseDate: String
  let starships: [String]
  
  enum CodingKeys: String, CodingKey {
    case id = "episode_id"
    case title
    case openingCrawl = "opening_crawl"
    case director
    case producer
    case releaseDate = "release_date"
    case starships
  }
}
