//
//  SplashViewController.swift
//  GAM
//
//  Created by Jungbin on 1/10/24.
//

import UIKit
import SnapKit
import FirebaseRemoteConfig

final class SplashViewController: BaseViewController {
    
    // MARK: UIComponents
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: .gamLogo)
        return imageView
    }()
    
    // MARK: Properties
    
    var remoteConfig: RemoteConfig?
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setLayout()
        self.checkUpdate()
    }
    
    // MARK: Methods
    
    private func setUI() {
        self.view.backgroundColor = .gamBlackLogo
    }
    
    private func autoSignIn() {
        // TODO: FCM
//        let deviceToken: String = UserInfo.shared.deviceToken
        
        let tokenData: RefreshTokenRequestDTO = .init(
            accessToken: UserDefaultsManager.accessToken ?? "",
            refreshToken: UserDefaultsManager.refreshToken ?? ""
        )
        
        self.requestRefreshToken(data: tokenData) { isProfileCompleted in
            self.presentNextViewController(isProfileCompleted: isProfileCompleted)
        }
    }
    
    private func presentNextViewController(isProfileCompleted: Bool) {
        if isProfileCompleted {
            self.present(GamTabBarController(), animated: true)
        } else {
            self.present(BaseNavigationController(rootViewController: SignUpUsernameViewController()), animated: true)
        }
    }
    
    private func checkUpdate() {
        self.remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 60 * 60 * 12
        self.remoteConfig?.configSettings = settings
        
        self.remoteConfig?.fetch { (status, error) -> Void in
            if status == .success {
                gamPrint("Config fetched!")
                self.remoteConfig?.activate { _, error in
                    let latestVersion: String = self.remoteConfig?.configValue(forKey: "latestVersion").stringValue ?? "0.0.0"
                    if AppInfo.shared.isUpdateNeeded(latest: latestVersion) {
                        DispatchQueue.main.async { [weak self] in
                            self?.present(GamUpdatePopupViewController(), animated: true)
                        }
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            self?.autoSignIn()
                        }
                    }
                }
            } else {
                gamPrint("Config not fetched")
                gamPrint("Error: \(error?.localizedDescription ?? "No error available.")")
                DispatchQueue.main.async { [weak self] in
                    self?.autoSignIn()
                }
            }
            
        }
    }
    

}

// MARK: - UI

extension SplashViewController {
    private func setLayout() {
        self.view.addSubviews([logoImageView])
        
        self.logoImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(180)
        }
    }
}
