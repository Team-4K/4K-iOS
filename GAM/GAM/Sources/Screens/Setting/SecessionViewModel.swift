//
//  SecessionViewModel.swift
//  GAM
//
//  Created by Juhyeon Byun on 1/23/24.
//

import Foundation
import RxSwift
import RxRelay

final class SecessionViewModel {
    
    // MARK: Properties
    
    private let networkService: AuthService
    private let disposeBag = DisposeBag()
    
    let reasons = [
        "매거진 컨텐츠가 유익하지 않아요.",
        "매거진 발행 주기가 늦어요.",
        "포트폴리오에서 영감을 얻지 못했어요.",
        "앱 오류가 자주 발생해요.",
        "직접 입력할게요."
    ]
    
    struct State {
        var selectedItems: [Int] = []
        let confirmButtonState: BehaviorRelay<Bool> = BehaviorRelay(value: false)
        let reasonText: BehaviorRelay<String> = BehaviorRelay(value: "")
    }
    
    struct Action {
        let deleteAccount = PublishSubject<Void>()
        let showNetworkErrorAlert = PublishRelay<Void>()
        let popViewController = PublishRelay<Void>()
    }

    var state = State()
    let action = Action()
    
    init(networkService: AuthService = AuthService.shared) {
        self.networkService = networkService
        self.setBinding()
    }
}

// MARK: - Methods

extension SecessionViewModel {
    
    private func setBinding() {
        self.state.reasonText
            .map { $0.isEmpty }
            .distinctUntilChanged()
            .subscribe(with: self, onNext: { owner, isEmpty in
                owner.state.confirmButtonState.accept(!isEmpty)
            })
            .disposed(by: self.disposeBag)
        
        self.action.deleteAccount
            .subscribe(onNext: { [weak self] in
                self?.deleteAccount() {
                    self?.removeUserInfo()
                    self?.action.popViewController.accept(())
                }
            })
            .disposed(by: disposeBag)
    }
    
    func checkConfirmButtonState(index: Int, isSelected: Bool) {
        if isSelected {
            self.state.selectedItems.append(index)
        } else {
            self.state.selectedItems.removeAll { $0 == index }
        }
        
        if self.state.selectedItems.isEmpty {
            self.state.confirmButtonState.accept(false)
        } else {
            let isLastItemSelected = self.state.selectedItems.contains(reasons.count - 1)
            self.state.confirmButtonState.accept(isLastItemSelected ? !self.state.reasonText.value.isEmpty : true)
        }

    }
    
    private func deleteAccount(completion: @escaping () -> ()) {
        gamPrint("❤️‍🔥", self.state.selectedItems, self.state.reasonText.value)
        self.networkService.requestSecession(data: SecessionRequestDTO(deleteAccountReasons: self.state.selectedItems,
                                                                       directInput: self.state.reasonText.value)) { networkResult in
            switch networkResult {
            case .success(_):
                completion()
            default:
                self.action.showNetworkErrorAlert.accept(())
            }
        }
    }
    
    func removeUserInfo() {
        UserDefaultsManager.userID = nil
        UserDefaultsManager.accessToken = nil
        UserDefaultsManager.refreshToken = nil
    }
}
