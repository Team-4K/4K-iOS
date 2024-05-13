//
//  AppDelegate.swift
//  GAM
//
//  Created by Jungbin on 2023/06/30.
//

import UIKit
import KakaoSDKCommon
import KakaoSDKAuth
import Firebase
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        KakaoSDK.initSDK(appKey: Environment.KAKAO_NATIVE_APP_KEY)
        
        FirebaseApp.configure()
        PushNotificationHelper.shared.setAuthorization()
        // 앱 실행 시 사용자에게 알림 허용 권한 받기
        UNUserNotificationCenter.current().delegate = self
        
        // 원격 알림 등록
        application.registerForRemoteNotifications()

        /// 메시지 대리자 설정
        Messaging.messaging().delegate = self
        
        /// 자동 초기화 방지
        Messaging.messaging().isAutoInitEnabled = true
        
        /// 현재 등록 토큰 가져오기
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                UserDefaultsManager.fcmDeviceToken = token
                UserInfo.shared.deviceToken = token 
            }
        }
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        
        return false
    }
    
    /// APN 토큰과 등록 토큰 매핑
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    /// APN 토큰과 등록 토큰 매핑 실패
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        gamPrint("APN 토큰 등록 실패", "fail")
    }
    
    /// 디바이스 세로방향으로 고정
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    /// 토큰 갱신 모니터링 메서드
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        UserDefaultsManager.fcmDeviceToken = fcmToken
        UserInfo.shared.deviceToken = fcmToken ?? "non-token"
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate: UNUserNotificationCenterDelegate {

    /// foreGround에 푸시알림이 올 때 실행되는 메서드
    func userNotificationCenter(_ center: UNUserNotificationCenter,willPresent notification: UNNotification,withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.badge, .sound, .list, .banner])
    }
}
