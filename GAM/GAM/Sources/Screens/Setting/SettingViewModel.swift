//
//  SettingViewModel.swift
//  GAM
//
//  Created by Juhyeon Byun on 1/16/24.
//

import Foundation
import RxSwift
import RxRelay


final class SettingViewModel {
    
    // MARK: Properties
    
    private let networkService: AuthService
    private let disposeBag = DisposeBag()
    
    private let menus: [[String: [String]]] = [["문의 및 피드백": ["문의하기"]],
                                       ["앱 정보": ["서비스 소개", "만든 사람들", "오픈소스 라이브러리", "버전 정보"]],
                                       ["약관 및 정책": ["서비스 이용약관", "개인정보처리방침"]],
                                       ["계정정보": ["로그아웃", "탈퇴하기"]]]
    lazy var categories: [String] = {
        return menus.flatMap { dictionary in
            return dictionary.keys
        }
    }()
    lazy var submenus: [[String]] = {
        return menus.flatMap { dictionary in
            return dictionary.values
        }
    }()
    
    struct Action {
        let logout = PublishSubject<Void>()
        let showNetworkErrorAlert = PublishRelay<Void>()
        let popViewController = PublishRelay<Void>()
    }

    let action = Action()

    // MARK: Life Cycle
    
    init(networkService: AuthService = AuthService.shared) {
        self.networkService = networkService
        self.setBinding()
    }
    
    // MARK: Methods
    
    private func setBinding() {
        self.action.logout
            .subscribe(onNext: { [weak self] in
                self?.logout() {
                    self?.removeUserInfo()
                    self?.action.popViewController.accept(())
                }
            })
            .disposed(by: disposeBag)
    }
    
    func removeUserInfo() {
        UserDefaultsManager.userID = nil
        UserDefaultsManager.accessToken = nil
        UserDefaultsManager.refreshToken = nil
    }
}

// MARK: - Network

extension SettingViewModel {
    private func logout(completion: @escaping () -> ()) {
        networkService.requestLogout(data: LogoutRequestDTO(accessToken: UserInfo.shared.accessToken, refreshToken: UserInfo.shared.accessToken)) { networkResult in
            switch networkResult {
            case .success(_):
                completion()
            default:
                self.action.showNetworkErrorAlert.accept(())
            }
        }
    }
}
