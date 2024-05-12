//
//  PublicService.swift
//  GAM
//
//  Created by Jungbin on 2023/08/23.
//

import Foundation
import Moya

internal protocol PublicServiceProtocol {
    func getGamURL(completion: @escaping (NetworkResult<Any>) -> (Void))
}

final class PublicService: BaseService {
    static let shared = PublicService()
    private lazy var provider = GamMoyaProvider<PublicRouter>(isLoggingOn: false)
//    let sampleProvider = MoyaProvider<PublicRouter>(session: Session(interceptor: AuthInterceptor.shared))
    
    private override init() {}
}

extension PublicService: PublicServiceProtocol {
    
    // [GET] 감 URL
    
    func getGamURL(completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.getGamURL) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, GamURLResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
}
