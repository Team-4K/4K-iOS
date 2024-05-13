//
//  MagazineRouter.swift
//  GAM
//
//  Created by Jungbin on 2023/08/24.
//

import Foundation
import Moya

enum MagazineRouter {
    case getPopularMagazine
    case getAllMagazine
    case getScrapMagazine
    case requestScrapMagazine(data: ScrapMagazineRequestDTO)
    case searchMagazine(data: String)
}

extension MagazineRouter: TargetType {
    
    var baseURL: URL {
        return URL(string: APIConstants.baseURL)!
    }
    
    var path: String {
        switch self {
        case .getPopularMagazine:
            return "/magazine/popular"
        case .getAllMagazine:
            return "/magazine"
        case .getScrapMagazine:
            return "/magazine/scraps"
        case .requestScrapMagazine:
            return "/magazine/scrap"
        case .searchMagazine:
            return "/magazine/search"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPopularMagazine, .getAllMagazine, .getScrapMagazine, .searchMagazine:
            return .get
        case .requestScrapMagazine:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .getPopularMagazine, .getAllMagazine, .getScrapMagazine:
            return .requestPlain
        case .requestScrapMagazine(let data):
            return .requestJSONEncodable(data)
        case .searchMagazine(let data):
            let body: [String : Any] = [
                "keyword": data
            ]
            return .requestParameters(parameters: body, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .getPopularMagazine, .getAllMagazine, .getScrapMagazine, .requestScrapMagazine, .searchMagazine:
            return [
                "Content-Type": "application/json",
                "Authorization": UserInfo.shared.accessToken
            ]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
