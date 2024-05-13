//
//  SignInViewController.swift
//  GAM
//
//  Created by Jungbin on 2023/06/30.
//

import UIKit
import SnapKit
import KakaoSDKUser
import AuthenticationServices

final class SignInViewController: BaseViewController {
    
    enum Text {
        static let info = "로그인 시 이용약관과 개인정보 처리 방침에 동의하게 됩니다."
        static let privacyPolicy = "개인정보 처리 방침"
        static let terms = "이용약관"
    }
    
    // MARK: UIComponents
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: .gamLogoKorean)
        return imageView
    }()
    
    private let appleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.appleLogin, for: .normal)
        return button
    }()
    
    private let kakaoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.kakaoLoginMediumWide, for: .normal)
        return button
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.text = Text.info
        label.textColor = .gamWhite
        label.font = .caption1Regular
        label.setHyperlinkedStyle(to: [Text.privacyPolicy, Text.terms], with: .caption1Regular)
        label.sizeToFit()
        return label
    }()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setLayout()
        self.setKakaoButtonAction()
        self.setAppleButtonAction()
        self.setPrivacyPolicyLabelTapRecognizer()
        self.fetchGamURL()
    }
    
    // MARK: Methods
    
    private func setUI() {
        self.view.backgroundColor = .gamBlackLogo
    }
    
    private func setKakaoButtonAction() {
        self.kakaoButton.setAction { [weak self] in
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                    if let error = error {
                        gamPrint(error)
                    }
                    else {
                        gamPrint("loginWithKakaoTalk() success.")
                        self?.requestSocialLogin(data: .init(token: oauthToken?.accessToken ?? "", socialType: .kakao, deviceToken: UserInfo.shared.deviceToken), isProfileCompleted: { bool in
                            self?.presentNextViewController(isProfileCompleted: bool)
                        })
                    }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { (oauthToken, error) in
                    if let error = error {
                        gamPrint(error)
                    }
                    else {
                        gamPrint("loginWithKakaoAccount() success.")
                        self?.requestSocialLogin(data: .init(token: oauthToken?.accessToken ?? "", socialType: .kakao, deviceToken: UserInfo.shared.deviceToken), isProfileCompleted: { bool in
                            self?.presentNextViewController(isProfileCompleted: bool)
                        })
                    }
                }
            }
        }
    }
    
    private func setPrivacyPolicyLabelTapRecognizer() {
        self.infoLabel.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(privacyPolicyLabelTapped)
        )
        self.infoLabel.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setAppleButtonAction() {
        self.appleButton.setAction { [weak self] in
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }
    
    @objc private func privacyPolicyLabelTapped(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.infoLabel)
        
        if let calaulatedTermsRect = self.infoLabel.boundingRectForCharacterRange(subText: Text.terms),
           calaulatedTermsRect.contains(point) {
            self.openSafariInApp(url: AppInfo.shared.url.agreement)
        }
        
        if let privacyPolicyRect = self.infoLabel.boundingRectForCharacterRange(subText: Text.privacyPolicy),
           privacyPolicyRect.contains(point) {
            self.openSafariInApp(url: AppInfo.shared.url.privacyPolicy)
        }
    }
    
    private func presentNextViewController(isProfileCompleted: Bool) {
        if isProfileCompleted {
            self.present(GamTabBarController(), animated: true)
        } else {
            self.present(BaseNavigationController(rootViewController: SignUpUsernameViewController()), animated: true)
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension SignInViewController: ASAuthorizationControllerDelegate {
    
    /// 사용자 인증 성공 시 인증 정보를 반환 받습니다.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            if let identityToken = appleIDCredential.identityToken,
               let tokenString = String(data: identityToken, encoding: .utf8) {
//                let fcmToken = UserDefaultsManager.fcmToken ?? ""
                self.requestSocialLogin(data: .init(token: tokenString, socialType: .apple, deviceToken: UserInfo.shared.deviceToken), isProfileCompleted: { bool in
                    self.presentNextViewController(isProfileCompleted: bool)
                })
            }
        default:
            break
        }
    }
    
    /// 사용자 인증 실패 시 에러 처리를 합니다.
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        gamPrint("apple 로그인 사용자 인증 실패")
        gamPrint("error \(error)")
        self.showNetworkErrorAlert()
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    
    /// 애플 로그인 UI를 어디에 띄울지 가장 적합한 뷰 앵커를 반환합니다.
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

// MARK: - Network

extension SignInViewController {
    private func requestSocialLogin(data: SocialLoginRequestDTO, isProfileCompleted: @escaping (Bool) -> (Void)) {
        self.startActivityIndicator()
        AuthService.shared.requestSocialLogin(data: data) { networkResult in
            switch networkResult {
            case .success(let responseData):
                if let result = responseData as? SocialLoginResponseDTO {
                    UserInfo.shared.userID = result.id
                    self.setUserInfo(
                        userID: result.id,
                        accessToken: result.accessToken,
                        refreshToken: result.refreshToken
                    )
                    isProfileCompleted(result.isProfileCompleted)
                }
            default:
                self.showNetworkErrorAlert()
            }
            self.stopActivityIndicator()
        }
    }
}

// MARK: - UI

extension SignInViewController {
    private func setLayout() {
        self.view.addSubviews([logoImageView, infoLabel, kakaoButton,  appleButton])
        
        self.logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(272.adjustedH)
            make.width.equalTo(110)
            make.height.equalTo(127)
        }
        
        self.infoLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(48)
        }
        
        self.kakaoButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.infoLabel.snp.top).offset(-12)
        }
        
        self.appleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.kakaoButton.snp.top).offset(-10)
        }
    }
}
