//
//  UserRouter.swift
//  GAM
//
//  Created by Jungbin on 2023/08/23.
//

import Foundation
import Moya

enum UserRouter {
    case requestSignUp(data: SignUpRequestDTO)
    case checkUsernameDuplicated(data: String)
    case getPopularDesigner
    case requestScrapDesigner(data: ScrapDesignerRequestDTO)
    case getBrowseDesigner(data: [Int])
    case getScrapDesigner
    case searchDesigner(data: String)
    case getUserProfile(data: GetUserProfileRequestDTO)
    case getUserPortfolio(data: GetUserPortfolioRequestDTO)
    case getPortfolio
    case setRepPortfolio(data: SetMyPortfolioRequestDTO)
    case deletePortfolio(data: SetMyPortfolioRequestDTO)
    case createPortfolio(data: CreatePortfolioRequestDTO)
    case getImageUrl(data: GetImageUrlRequestDTO)
    case uploadImage(data: UploadImageRequestDTO)
    case updateLink(contactUrlType: ContactURLType, data: UpdateLinkRequestDTO)
    case updatePortfolio(data: UpdateMyPortfolioRequestDTO)
    case getProfile
    case updateProfile(data: UpdateMyProfileRequestDTO)
    case blockUser(data: BlockUserRequestDTO)
}

extension UserRouter: TargetType {
    
    var baseURL: URL {
        switch self {
        case .getBrowseDesigner(let data):
            let path = APIConstants.baseURL + "/user"
            var queryPath = "?"
            for i in data {
                queryPath += "tags=\(i)&"
            }
            queryPath.removeLast()
            return URL(string: URL(string: path)!.appendingPathComponent(queryPath).absoluteString.removingPercentEncoding ?? path)!
        case .uploadImage(let data):
            return URL(string: data.uploadUrl)!
        default:
            return URL(string: APIConstants.baseURL)!
        }
    }
    
    var path: String {
        switch self {
        case .requestSignUp:
            return "/user/onboard"
        case .checkUsernameDuplicated:
            return "/user/name/check"
        case .getPopularDesigner:
            return "/user/popular"
        case .requestScrapDesigner:
            return "/user/scrap"
        case .getBrowseDesigner:
            return ""
        case .getScrapDesigner:
            return "/user/scraps"
        case .searchDesigner:
            return "/user/search"
        case .getUserProfile:
            return "/user/detail/profile"
        case .getUserPortfolio(let data):
            return "/user/portfolio/\(data.userId)"
        case .getPortfolio:
            return "/user/my/portfolio"
        case .setRepPortfolio:
            return "/work/main"
        case .deletePortfolio, .createPortfolio:
            return "/work"
        case .getImageUrl:
            return "/s3/image"
        case .uploadImage:
            return ""
        case .updateLink(let contactUrlType, _):
            return "/user/link/\(contactUrlType.rawValue)"
        case .updatePortfolio:
            return "/work/edit"
        case .getProfile:
            return "/user/my/profile"
        case .updateProfile:
            return "/user/introduce"
        case .blockUser:
            return "/block"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .requestSignUp, .requestScrapDesigner, .createPortfolio, .blockUser:
            return .post
        case .checkUsernameDuplicated, .getPopularDesigner, .getBrowseDesigner, .getScrapDesigner, .searchDesigner, .getUserProfile, .getUserPortfolio, .getPortfolio, .getImageUrl, .getProfile:
            return .get
        case .setRepPortfolio, .updateLink, .updatePortfolio, .updateProfile:
            return .patch
        case .deletePortfolio:
            return .delete
        case .uploadImage:
            return .put
        }
    }
    
    var task: Task {
        switch self {
        case .requestSignUp(let data):
            return .requestJSONEncodable(data)
        case .checkUsernameDuplicated(let data):
            let body: [String: Any] = [
                "userName": data
            ]
            return .requestParameters(parameters: body, encoding: URLEncoding.queryString)
        case .getPopularDesigner, .getBrowseDesigner, .getScrapDesigner, .getUserPortfolio, .getPortfolio, .getProfile:
            return .requestPlain
        case .requestScrapDesigner(let data):
            return .requestJSONEncodable(data)
        case .searchDesigner(let data):
            let body: [String : Any] = [
                "keyword": data
            ]
            return .requestParameters(parameters: body, encoding: URLEncoding.queryString)
        case .getUserProfile(let data):
             let query: [String: Any] = [
                 "userId": data.userId
             ]
             return .requestParameters(parameters: query, encoding: URLEncoding.queryString)
        case .setRepPortfolio(let data), .deletePortfolio(let data):
            return .requestJSONEncodable(data)
        case .createPortfolio(let data):
            return .requestJSONEncodable(data)
        case .getImageUrl(let data):
            let params: [String: Any] = [
                "fileName": data.imageName
            ]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        case .uploadImage(let data):
            return .requestData(data.imageData.jpegData(compressionQuality: 0.8) ?? Data())
        case .updateLink(_, let data):
            return .requestJSONEncodable(data)
        case .updatePortfolio(let data):
            return .requestJSONEncodable(data)
        case .updateProfile(let data):
            return .requestJSONEncodable(data)
        case .blockUser(let data):
            return .requestJSONEncodable(data)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .checkUsernameDuplicated:
            return ["Content-Type": "application/json"]
        case .uploadImage:
            return ["Content-Type": "image/jpeg"]
        default:
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
