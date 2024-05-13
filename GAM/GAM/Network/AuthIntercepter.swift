//
//  AuthIntercepter.swift
//  GAM
//
//  Created by Jungbin on 5/11/24.
//

import Foundation
import Alamofire

final class AuthInterceptor: RequestInterceptor {

    static let shared = AuthInterceptor()

    private init() {}

    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        let accessToken = UserInfo.shared.accessToken
        let refreshToken = UserInfo.shared.refreshToken
        
        var urlRequest = urlRequest
        urlRequest.setValue(accessToken, forHTTPHeaderField: "Authorization")
        completion(.success(urlRequest))
    }

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        print("retry 진입")
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401
        else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        let accessToken = UserInfo.shared.accessToken
        let refreshToken = UserInfo.shared.refreshToken
        
        AuthService.shared.requestRefreshToken(data: RefreshTokenRequestDTO(accessToken: accessToken, refreshToken: refreshToken)) { networkResult in
            switch networkResult {
            case .success(let responseData):
                if let result = responseData as? RefreshTokenResponseDTO {
                    UserInfo.shared.accessToken = result.accessToken
                    UserInfo.shared.refreshToken = result.refreshToken
                    
                    UserDefaultsManager.accessToken = result.accessToken
                    UserDefaultsManager.refreshToken = result.refreshToken
                    
                    completion(.retry)
                }
            case .requestErr:
                UserDefaultsManager.userID = nil
                UserDefaultsManager.accessToken = nil
                UserDefaultsManager.refreshToken = nil
                completion(.doNotRetry)
            default:
                debugPrint("Refresh Token error")
                completion(.doNotRetry)
            }
        }
    }
}
