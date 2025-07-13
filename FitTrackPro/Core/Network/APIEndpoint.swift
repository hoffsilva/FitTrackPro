import Foundation
import Alamofire

enum APIEndpoint {
    case exercises(PaginationParameters?)
    case exercisesByBodyPart(bodyPart: String, parameters: PaginationParameters?)
    case exercisesByTarget(target: String, parameters: PaginationParameters?)
    case exercisesByEquipment(equipment: String, parameters: PaginationParameters?)
    case bodyPartList
    case targetList
    case equipmentList
    case exerciseImage(ImageParameters)
    
    var path: String {
        switch self {
        case .exercises:
            return APIConstants.Endpoints.exercises
        case .exercisesByBodyPart(let bodyPart, _):
            return APIConstants.Endpoints.exercisesByBodyPart + "/\(bodyPart)"
        case .exercisesByTarget(let target, _):
            return APIConstants.Endpoints.exercisesByTarget + "/\(target)"
        case .exercisesByEquipment(let equipment, _):
            return APIConstants.Endpoints.exercisesByEquipment + "/\(equipment)"
        case .bodyPartList:
            return APIConstants.Endpoints.bodyPartList
        case .targetList:
            return APIConstants.Endpoints.targetList
        case .equipmentList:
            return APIConstants.Endpoints.equipmentList
        case .exerciseImage:
            return APIConstants.Endpoints.image
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var parameters: Parameters? {
        switch self {
        case .exercises(let params),
             .exercisesByBodyPart(_, let params),
             .exercisesByTarget(_, let params),
             .exercisesByEquipment(_, let params):
            return params?.toDictionary()
        case .exerciseImage(let params):
            return params.toDictionary()
        case .bodyPartList, .targetList, .equipmentList:
            return nil
        }
    }
    
    var encoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var url: String {
        return APIConstants.baseURL + path
    }
    
    func headers(with apiKey: String) -> HTTPHeaders {
        return [
            APIConstants.Headers.rapidAPIKey: apiKey,
            APIConstants.Headers.rapidAPIHost: APIConstants.Values.rapidAPIHost,
            APIConstants.Headers.contentType: APIConstants.Values.contentTypeJSON
        ]
    }
}