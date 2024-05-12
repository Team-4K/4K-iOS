//
//  PublicRouter.swift
//  GAM
//
//  Created by Jungbin on 2023/08/23.
//

import Foundation
import Moya

enum PublicRouter {
    case getGamURL
}

extension PublicRouter: TargetType {
    
    var baseURL: URL {
        return URL(string: APIConstants.baseURL)!
    }
    
    var path: String {
        switch self {
        case .getGamURL:
            return "/url"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getGamURL:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .getGamURL:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        switch self {
        default:
            return ["Content-Type": "application/json"]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
