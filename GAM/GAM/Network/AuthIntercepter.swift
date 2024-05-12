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
        guard urlRequest.url?.absoluteString.hasPrefix(APIConstants.baseURL) == true
        else {
            completion(.success(urlRequest))
            return
        }
        
        var urlRequest = urlRequest
        urlRequest.setValue(accessToken, forHTTPHeaderField: "accessToken")
        urlRequest.setValue(refreshToken, forHTTPHeaderField: "refreshToken")
        print("adaptor 적용 \(urlRequest.headers)")
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
        
        // 토큰 갱신 API 호출
        AuthService.shared.requestRefreshToken(data: RefreshTokenRequestDTO(accessToken: accessToken, refreshToken: refreshToken)) { networkResult in
            switch networkResult {
            case .success(let responseData):
                if let result = responseData as? RefreshTokenResponseDTO {
                    UserInfo.shared.accessToken = result.accessToken
                    UserInfo.shared.refreshToken = result.refreshToken
                    
                    UserDefaultsManager.accessToken = result.accessToken
                    UserDefaultsManager.refreshToken = result.refreshToken
                    // TODO: 이자식 왜이럴까? 여기서 무한호출되는듯 
//                    completion(.retry)
                }
            case .requestErr:
                UserDefaultsManager.userID = nil
                UserDefaultsManager.accessToken = nil
                UserDefaultsManager.refreshToken = nil
            default:
                debugPrint("Refresh Token error")
            }
        }
//        AuthService.shared.getNewToken { result in
//            switch result {
//            case .success:
//                print("Retry-토큰 재발급 성공")
//                completion(.retry)
//            case .failure(let error):
//                // 갱신 실패 -> 로그인 화면으로 전환
//                completion(.doNotRetryWithError(error))
//            }
//        }
    }
}
