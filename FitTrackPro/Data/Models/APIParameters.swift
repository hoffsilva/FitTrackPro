import Foundation

struct PaginationParameters: Codable {
    let limit: Int?
    let offset: Int?
    
    init(limit: Int? = nil, offset: Int? = nil) {
        self.limit = limit
        self.offset = offset
    }
}