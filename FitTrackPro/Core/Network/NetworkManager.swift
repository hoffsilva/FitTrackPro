import Foundation
import Alamofire

protocol NetworkManagerProtocol {
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T
}

class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()
    
    private let session: Session
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = APIConstants.timeout
        configuration.timeoutIntervalForResource = APIConstants.timeout
        
        self.session = Session(configuration: configuration)
    }
    
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                endpoint.url,
                method: endpoint.method,
                parameters: endpoint.parameters,
                encoding: endpoint.encoding,
                headers: endpoint.headers(with: APIConstants.rapidAPIKey)
            )
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    let networkError = self.mapError(error, statusCode: response.response?.statusCode)
                    continuation.resume(throwing: networkError)
                }
            }
        }
    }
    
    private func mapError(_ error: AFError, statusCode: Int?) -> NetworkError {
        if let statusCode = statusCode {
            switch statusCode {
            case 401:
                return .unauthorized
            case 403:
                return .forbidden
            case 404:
                return .notFound
            case 429:
                return .rateLimitExceeded
            case 500...599:
                return .serverError(statusCode)
            default:
                break
            }
        }
        
        switch error {
        case .sessionTaskFailed(let sessionError):
            if let urlError = sessionError as? URLError {
                switch urlError.code {
                case .timedOut:
                    return .timeout
                case .notConnectedToInternet, .networkConnectionLost:
                    return .networkError(urlError)
                default:
                    return .networkError(urlError)
                }
            }
            return .networkError(sessionError)
        case .responseSerializationFailed:
            return .decodingError(error)
        default:
            return .networkError(error)
        }
    }
}
