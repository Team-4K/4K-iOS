//
//  MagazineService.swift
//  GAM
//
//  Created by Jungbin on 2023/08/24.
//

import Foundation
import Moya

internal protocol MagazineServiceProtocol {
    func getPopularMagazine(completion: @escaping (NetworkResult<Any>) -> (Void))
    func getAllMagazine(completion: @escaping (NetworkResult<Any>) -> (Void))
    func getScrapMagazine(completion: @escaping (NetworkResult<Any>) -> (Void))
    func requestScrapMagazine(data: ScrapMagazineRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void))
    func searchMagazine(data: String, completion: @escaping (NetworkResult<Any>) -> (Void))
}

final class MagazineService: BaseService {
    static let shared = MagazineService()
    private lazy var provider = GamMoyaProvider<MagazineRouter>(isLoggingOn: true)
    
    private override init() {}
}

extension MagazineService: MagazineServiceProtocol {
    
    // [GET] 영감 매거진
    
    func getPopularMagazine(completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.getPopularMagazine) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, MagazineResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [GET] 모든 매거진(발견)
    
    func getAllMagazine(completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.getAllMagazine) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, MagazineResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [GET] 스크랩 매거진
    
    func getScrapMagazine(completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.getScrapMagazine) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, ScrapMagazineResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [PUT] 매거진 스크랩 on/off
    
    func requestScrapMagazine(data: ScrapMagazineRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.requestScrapMagazine(data: data)) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, ScrapMagazineRequestDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [GET] 매거진 검색
    
    func searchMagazine(data: String, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.searchMagazine(data: data)) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, SearchMagazineResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
}
