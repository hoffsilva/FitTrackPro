import Foundation

struct GifURLBuilder {
    static func buildURL(for exerciseId: String, resolution: ImageResolution = .medium) -> String {
        let baseURL = APIConstants.baseURL
        let endpoint = APIConstants.Endpoints.image
        let apiKey = APIConstants.rapidAPIKey
        
        return "\(baseURL)\(endpoint)?exerciseId=\(exerciseId)&resolution=\(resolution.rawValue)&rapidapi-key=\(apiKey)"
    }
}