import Foundation

enum ImageResolution: String, Codable, CaseIterable {
    case low = "180"
    case medium = "360"
    case high = "720"
    case ultraHigh = "1080"
    
    var displayName: String {
        switch self {
        case .low:
            return "180p"
        case .medium:
            return "360p"
        case .high:
            return "720p"
        case .ultraHigh:
            return "1080p"
        }
    }
}

struct ImageParameters: Codable {
    let exerciseId: String
    let resolution: ImageResolution
    
    init(exerciseId: String, resolution: ImageResolution = .medium) {
        self.exerciseId = exerciseId
        self.resolution = resolution
    }
}