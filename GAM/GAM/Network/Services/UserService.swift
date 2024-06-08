//
//  UserService.swift
//  GAM
//
//  Created by Jungbin on 2023/08/23.
//

import Foundation
import Moya

internal protocol UserServiceProtocol {
    func requestSignUp(data: SignUpRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void))
    func checkUsernameDuplicated(data: String, completion: @escaping (NetworkResult<Any>) -> (Void))
    func getPopularDesigner(completion: @escaping (NetworkResult<Any>) -> (Void))
    func requestScrapDesigner(data: ScrapDesignerRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void))
    func getBrowseDesigner(data: [Int], completion: @escaping (NetworkResult<Any>) -> (Void))
    func getScrapDesigner(completion: @escaping (NetworkResult<Any>) -> (Void))
    func searchDesigner(data: String, completion: @escaping (NetworkResult<Any>) -> (Void))
    func getUserProfile(data: GetUserProfileRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void))
    func getUserPortfolio(data: GetUserPortfolioRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void))
    func getPortfolio(completion: @escaping (NetworkResult<Any>) -> (Void))
    func setRepPortfolio(data: SetMyPortfolioRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void))
    func deletePortfolio(data: SetMyPortfolioRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void))
    func createPortfolio(data: CreatePortfolioRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void))
    func getImageUrl(data: GetImageUrlRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void))
    func uploadImage(data: UploadImageRequestDTO, completion: @escaping () -> ())
    func updateLink(contactUrlType: ContactURLType, data: UpdateLinkRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void))
    func updatePortfolio(data: UpdateMyPortfolioRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void))
    func getProfile(completion: @escaping (NetworkResult<Any>) -> (Void))
    func blockUser(data: BlockUserRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void))
    func checkPermission(completion: @escaping (NetworkResult<Any>) -> (Void))
}

final class UserService: BaseService {
    static let shared = UserService()
    private lazy var provider = GamMoyaProvider<UserRouter>(isLoggingOn: true)
    
    private override init() {}
}

extension UserService: UserServiceProtocol {
    
    // [POST] 회원가입
    
    func requestSignUp(data: SignUpRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.requestSignUp(data: data)) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, SocialLoginResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [GET] 닉네임 중복 검사
    
    func checkUsernameDuplicated(data: String, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.checkUsernameDuplicated(data: data)) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, CheckUsernameDuplicatedResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [GET] 감 잡은 디자이너
    
    func getPopularDesigner(completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.getPopularDesigner) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, PopularDesignerResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [POST] 디자이너 스크랩
    
    func requestScrapDesigner(data: ScrapDesignerRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.requestScrapDesigner(data: data)) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, ScrapDesignerResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [GET] 발견 - 디자이너
    
    func getBrowseDesigner(data: [Int], completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.getBrowseDesigner(data: data)) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, GetBrowseDesignerResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [GET] 발견 - 디자이너 스크랩
    
    func getScrapDesigner(completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.getScrapDesigner) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, GetScrapDesignerResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [GET] 디자이너 검색
    
    func searchDesigner(data: String, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.searchDesigner(data: data)) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, SearchDesignerResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [GET] 유저 프로필 조회
    
    func getUserProfile(data: GetUserProfileRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.getUserProfile(data: data)) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, GetUserProfileResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [GET] 유저 포트폴리오 조회
    
    func getUserPortfolio(data: GetUserPortfolioRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.getUserPortfolio(data: data)) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, GetUserPortfolioResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [GET] 포트폴리오 리스트 조회
    
    func getPortfolio(completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.getPortfolio) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, GetMyPortfolioResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [PATCH] 대표 프로젝트로 설정
    
    func setRepPortfolio(data: SetMyPortfolioRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.setRepPortfolio(data: data)) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, String.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [DELETE] 프로젝트 삭제
    func deletePortfolio(data: SetMyPortfolioRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.deletePortfolio(data: data)) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, SetDefaultMyPortfolioResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [POST] 프로젝트 생성
    func createPortfolio(data: CreatePortfolioRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.createPortfolio(data: data)) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, SetDefaultMyPortfolioResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [GET] 이미지 url 받아오기
    func getImageUrl(data: GetImageUrlRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.getImageUrl(data: data)) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, GetImageUrlResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [PUT] 이미지 업로드
    func uploadImage(data: UploadImageRequestDTO, completion: @escaping () -> ()) {
        self.provider.request(.uploadImage(data: data)) { result in
            switch result {
            case .success(_):
                completion()
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [PATCH] 링크 업데이트
    func updateLink(contactUrlType: ContactURLType, data: UpdateLinkRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.updateLink(contactUrlType: contactUrlType, data: data)) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, String.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [PATCH] 프로젝트 수정
    func updatePortfolio(data: UpdateMyPortfolioRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.updatePortfolio(data: data)) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, SetDefaultMyPortfolioResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [GET] 프로필 조회
    func getProfile(completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.getProfile) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, GetMyProfileResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [PATCH] 프로필 업데이트
    func updateProfile(data: UpdateMyProfileRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.updateProfile(data: data)) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, UpdateProfileResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [POST] 유저 차단
    func blockUser(data: BlockUserRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.blockUser(data: data)) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                
                // TODO: - 제네릭 타입 변경해야됨
                let networkResult = self.judgeStatus(by: statusCode, data, String.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [POST] 유저 신고
    func reportUser(data: ReportUserRequestDTO, completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.reportUser(data: data)) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                
                // TODO: - 제네릭 타입 변경해야됨
                let networkResult = self.judgeStatus(by: statusCode, data, String.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
    
    // [GET] 매거진 조회 권한 확인
    func checkPermission(completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.checkPermission) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                
                // TODO: - 제네릭 타입 변경해야됨
                let networkResult = self.judgeStatus(by: statusCode, data, CheckPermissionResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                gamPrint(error)
            }
        }
    }
}
