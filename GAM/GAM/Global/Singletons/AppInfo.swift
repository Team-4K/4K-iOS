//
//  AppInfo.swift
//  GAM
//
//  Created by Jungbin on 2023/08/23.
//

import Foundation

final class AppInfo {
    static var shared = AppInfo()
    
    init() { }
    
    var url: GamURLEntity = .init(
        intro: "",
        privacyPolicy: "",
        agreement: "",
        makers: "",
        openSource: ""
    )
    
    let appID: String = "6477517719"
    
    func currentAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }
    
    func isUpdateNeeded(latest: String) -> Bool {
        let current: String = self.currentAppVersion()
        
        let latestMajor: Int = Int(latest.indexing(0)) ?? 0
        let currentMajor: Int = Int(current.indexing(0)) ?? 0
        
        let latestMinor: Int = Int(latest.indexing(2)) ?? 0
        let currentMinor: Int = Int(current.indexing(2)) ?? 0
        
        return latestMajor > currentMajor || latestMinor > currentMinor
    }
}
