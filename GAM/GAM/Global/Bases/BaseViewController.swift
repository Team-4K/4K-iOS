//
//  BaseViewController.swift
//  GAM
//
//  Created by Jungbin on 2023/06/30.
//

import UIKit
import MessageUI

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: Properties
    
    lazy var activityIndicator: GamActivityIndicatorView = {
        let activityIndicator: GamActivityIndicatorView = GamActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        activityIndicator.center = self.view.center
        
        return activityIndicator
    }()
    
    let screenWidth = UIScreen.main.bounds.size.width
    let screenHeight = UIScreen.main.bounds.size.height
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setBackgroundColor()
        self.hideKeyboardWhenTappedAround()
    }
}

// MARK: Methods

extension BaseViewController {
    func hideTabBar() {
        if let tabBarController = self.tabBarController as? GamTabBarController {
            tabBarController.hideTabBar()
        }
    }
    
    func showTabBar() {
        if let tabBarController = self.tabBarController as? GamTabBarController {
            tabBarController.showTabBar()
        }
    }
    
    /// 화면 터치 시 키보드 내리는 메서드
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.delegate = self
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    /// 모든 뷰의 기본 Background color 설정
    private func setBackgroundColor() {
        self.view.backgroundColor = .gamGray1
    }
    
    /// 서버 통신 시작 시 Activity Indicator를 시작하는 메서드
    func startActivityIndicator() {
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.startAnimating()
    }
    
    /// 서버 통신이 끝나면 Activity Indicator를 종료하는 메서드
    func stopActivityIndicator() {
        self.activityIndicator.stopAnimating()
        self.activityIndicator.removeFromSuperview()
    }
    
    /// BackButton에 pop Action을 간편하게 주는 메서드.
    /// - 필요 시 override하여 사용
    @objc
    func setBackButtonAction(_ button: UIButton) {
        button.setAction { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    func openUserBlockReportActionSheet(username: String, userID: Int) {
        let actionSheet: UIAlertController = UIAlertController(
            title: nil,
            message: "\(username) 님",
            preferredStyle: .actionSheet
        )
        
        actionSheet.addAction(
            UIAlertAction(
                title: "차단하기",
                style: .default,
                handler: { _ in
                    self.makeAlertWithCancel(
                        title: "\(username) 님을 차단합니다.",
                        message: """
\(username) 님의 포트폴리오 및
프로필을 더이상 볼 수 없습니다.
""",
                        okTitle: "차단") { _ in
                            let dto = BlockUserRequestDTO(targetUserId: userID, currentBlockStatus: false)
                            UserService.shared.blockUser(data: dto) { networkResult in
                                switch networkResult {
                                case .success:
                                    self.navigationController?.popViewController(animated: true)
                                    self.navigationController?.topViewController?.showToastMessage(type: .completedUserBlock)
                                default:
                                    self.showNetworkErrorAlert()
                                }
                                self.stopActivityIndicator()
                            }
                        }
                }
            )
        )
        
        actionSheet.addAction(
            UIAlertAction(
                title: "신고하기",
                style: .destructive,
                handler: { _ in
                    self.makeAlertWithTextField(
                        title: "\(username) 님을 신고합니다.",
                        placeHolder: "신고 내용을 입력해주세요.",
                        okTitle: "신고") { content in
                            let dto = ReportUserRequestDTO(targetUserId: userID, content: content)
                            UserService.shared.reportUser(data: dto) { networkResult in
                                switch networkResult {
                                case .success:
                                    self.navigationController?.popViewController(animated: true)
                                    self.navigationController?.topViewController?.showToastMessage(type: .completedUserReport)
                                case .requestErr(let error):
                                    if error as! String == "이미 신고 한 유저입니다. 신고 처리 진행중" {
                                        self.showToastMessage(type: .completedUserReport)
                                    } else {
                                        self.showNetworkErrorAlert()
                                    }
                                default:
                                    self.showNetworkErrorAlert()
                                }
                                self.stopActivityIndicator()
                            }
                        }
                }
            )
        )
        
        actionSheet.addAction(
            UIAlertAction(
                title: "취소",
                style: .cancel,
                handler: nil
            )
        )
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func openUserContactEmailActionSheet(email: String) {
        let actionSheet: UIAlertController = UIAlertController(
            title: nil,
            message: email,
            preferredStyle: .actionSheet
        )
        
        actionSheet.addAction(
            UIAlertAction(
                title: "복사하기",
                style: .default,
                handler: { _ in
                    UIPasteboard.general.string = email
                    self.showToastMessage(type: .completedCopy)
                }
            )
        )
        
        actionSheet.addAction(
            UIAlertAction(
                title: "이메일 보내기",
                style: .default,
                handler: { _ in
                    self.openMailAppToUserEmail(email: email)
                }
            )
        )
        
        actionSheet.addAction(
            UIAlertAction(
                title: "취소",
                style: .cancel,
                handler: nil
            )
        )
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func showNetworkErrorAlert() {
        self.makeAlert(title: Message.networkError.text)
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension BaseViewController: MFMailComposeViewControllerDelegate {
    func openMailAppToUserEmail(email: String) {
        if MFMailComposeViewController.canSendMail() {
            let compseVC = MFMailComposeViewController()
            compseVC.mailComposeDelegate = self
            
            compseVC.setToRecipients([email])
            compseVC.setMessageBody(
"""


——————————————————————————
GAM 앱에서 보냈습니다.
"""
                , isHTML: false)
            
            self.present(compseVC, animated: true, completion: nil)
            
        } else {
            self.makeAlert(title: Message.unabledMailApp.text)
        }
    }
    
    func sendContactMail() {
        if MFMailComposeViewController.canSendMail() {
            let compseVC = MFMailComposeViewController()
            compseVC.mailComposeDelegate = self
            
            compseVC.setToRecipients(["must4rdev@gmail.com"])
            compseVC.setSubject("[감] 문의해요 👋")
            compseVC.setMessageBody(
"""
안녕하세요.
서비스를 이용주셔서 감사해요.
개선했으면 하는 부분 혹은 추가되었으면 하는 기능은 적극 반영해볼게요.
문의에 대한 답변은 빠른 시일내에 전송해주신 메일로 회신드리겠습니다.
——————————————————————————





——————————————————————————
User: \(String(describing: UserInfo.shared.userID))
App Version: \(AppInfo.shared.currentAppVersion())
Device: \(self.deviceModelName())
OS Version: \(UIDevice.current.systemVersion)
"""
                , isHTML: false)
            
            self.present(compseVC, animated: true, completion: nil)
            
        } else {
            self.makeAlert(title: Message.unabledMailApp.text)
        }
    }
    
    private func deviceModelName() -> String {
        
        /// 시뮬레이터 확인
        var modelName = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] ?? ""
        if modelName.isEmpty == false && modelName.count > 0 {
            return modelName
        }
        
        /// 실제 디바이스 확인
        let device = UIDevice.current
        let selName = "_\("deviceInfo")ForKey:"
        let selector = NSSelectorFromString(selName)
        
        if device.responds(to: selector) {
            modelName = String(describing: device.perform(selector, with: "marketing-name").takeRetainedValue())
        }
        return modelName
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            switch result {
            case .cancelled, .saved: return
            case .sent:
                self.makeAlert(title: Message.completedSendContactMail.text)
            case .failed:
                self.makeAlert(title: Message.failedSendContactMail.text)
            @unknown default:
                self.makeAlert(title: Message.networkError.text)
            }
        }
    }
    
    func setUserInfo(userID: Int, accessToken: String, refreshToken: String) {
        UserInfo.shared.userID = userID
        UserInfo.shared.accessToken = accessToken
        UserInfo.shared.refreshToken = refreshToken
        
        UserDefaultsManager.userID = userID
        UserDefaultsManager.accessToken = accessToken
        UserDefaultsManager.refreshToken = refreshToken
    }
    
    func removeUserInfo() {
        UserDefaultsManager.userID = nil
        UserDefaultsManager.accessToken = nil
        UserDefaultsManager.refreshToken = nil
    }
}

// MARK: - Network

extension BaseViewController {
    func fetchGamURL() {
        self.startActivityIndicator()
        PublicService.shared.getGamURL { networkResult in
            switch networkResult {
            case .success(let responseData):
                if let result = responseData as? GamURLResponseDTO {
                    AppInfo.shared.url = result.toEntity()
                }
            default:
                self.showNetworkErrorAlert()
            }
            self.stopActivityIndicator()
        }
    }
    
    func requestScrapMagazine(data: ScrapMagazineRequestDTO, completion: @escaping () -> ()) {
        MagazineService.shared.requestScrapMagazine(data: data) { networkResult in
            switch networkResult {
            case .success(let response):
                if let result = response as? ScrapMagazineRequestDTO {
                    if result.currentScrapStatus {
                        self.navigationController?.topViewController?.showToastMessage(type: .completedScrap)
                    }
                    completion()
                }
            default:
                self.showNetworkErrorAlert()
            }
        }
    }
    
    func requestScrapDesigner(data: ScrapDesignerRequestDTO, completion: @escaping () -> ()) {
        UserService.shared.requestScrapDesigner(data: data) { networkResult in
            switch networkResult {
            case .success(let response):
                if let result = response as? ScrapDesignerResponseDTO {
                    if result.userScrap {
                        self.navigationController?.topViewController?.showToastMessage(type: .completedScrap)
                    }
                    completion()
                }
            default:
                self.showNetworkErrorAlert()
            }
        }
    }
    
    func requestRefreshToken(data: RefreshTokenRequestDTO, isProfileCompleted: @escaping (Bool) -> (Void)) {
        self.startActivityIndicator()
        AuthService.shared.requestRefreshToken(data: data) { networkResult in
            switch networkResult {
            case .success(let responseData):
                if let result = responseData as? RefreshTokenResponseDTO {
                    self.setUserInfo(
                        userID: result.id,
                        accessToken: result.accessToken,
                        refreshToken: result.refreshToken
                    )
                    isProfileCompleted(result.isProfileCompleted)
                }
            case .requestErr:
                self.removeUserInfo()
                let signInViewController: BaseViewController = SignInViewController()
                signInViewController.modalTransitionStyle = .crossDissolve
                signInViewController.modalPresentationStyle = .fullScreen
                self.present(signInViewController, animated: true)
            default:
                self.showNetworkErrorAlert()
            }
            self.stopActivityIndicator()
        }
    }
}
