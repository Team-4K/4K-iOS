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
        intro: "https://www.notion.so/ABOUT-GAM-4789adaf556a4fd28c95854d77fae0df",
        privacyPolicy: "https://www.notion.so/37cbdfbcba564512b5bbe7ffa5920de0",
        agreement: "https://www.notion.so/680b662811b74a7080a54750b24aa03e",
        makers: "https://www.notion.so/WHO-MAKE-THIS-CREATIVE-SERVICE-811456b4bfaa4adcabcb48bba24b5b88",
        openSource: "https://www.notion.so/5e91d3af2439425c97acad9413bdcf3c?pvs=4"
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
