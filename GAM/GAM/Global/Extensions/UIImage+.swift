//
//  UIImage+.swift
//  GAM
//
//  Created by Jungbin on 2023/06/30.
//

import UIKit.UIImage

extension UIImage {
    
    static let kakaoLoginMediumWide: UIImage = UIImage(named: "kakao_login_medium_wide") ?? UIImage()
    
    static let appleLogin: UIImage = (UIImage(named: "apple_login") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let gamLogoKorean: UIImage = UIImage(named: "gamLogoKorean") ?? UIImage()
    
    static let textFieldClear: UIImage = (UIImage(named: "textFieldClear") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let chevronLeft: UIImage = (UIImage(named: "typeChevronLeft") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let defaultImage: UIImage = (UIImage(named: "defaultImage") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let scrapOn: UIImage = (UIImage(named: "icon_Scrap_on") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let scrapOff: UIImage = (UIImage(named: "icon_Scrap_off") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let scrapOnWhite: UIImage = (UIImage(named: "icon_Scrap_on_White") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let scrapOffWhite: UIImage = (UIImage(named: "icon_Scrap_off_White") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let visibilityBlack: UIImage = (UIImage(named: "visibility_black") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let visibilityGray: UIImage = (UIImage(named: "visibilityGray") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let icnShare: UIImage = (UIImage(named: "icnShare") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let icnSearch: UIImage = (UIImage(named: "icnSearch") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let icnFilterBlack: UIImage = (UIImage(named: "icnFilterBlack") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let icnFilterGray: UIImage = (UIImage(named: "icnFilterGray") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let icnSmallX: UIImage = (UIImage(named: "icnSmallX") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let icnModalX: UIImage = (UIImage(named: "icnModalX") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let icnMoreDefault: UIImage = (UIImage(named: "icnMoreDefault") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let behanceOff: UIImage = (UIImage(named: "behanceOff") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let behanceOn: UIImage = (UIImage(named: "behanceOn") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let instagramOff: UIImage = (UIImage(named: "instagramOff") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let instagramOn: UIImage = (UIImage(named: "instagramOn") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let notionOff: UIImage = (UIImage(named: "notionOff") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let notionOn: UIImage = (UIImage(named: "notionOn") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let emailOff: UIImage = (UIImage(named: "emailOff") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let emailOn: UIImage = (UIImage(named: "emailOn") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let icnSetting: UIImage = (UIImage(named: "icnSetting") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let icnCircleMore: UIImage = (UIImage(named: "icnCircleMore") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let icnUploadImage: UIImage = (UIImage(named: "icnUploadImage") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let icnPhoto: UIImage = (UIImage(named: "icnPhoto") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let checkboxOn: UIImage = (UIImage(named: "checkboxOn") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    static let checkboxOff: UIImage = (UIImage(named: "checkboxOff") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    func resizedToGamSize() -> UIImage {
        return UIGraphicsImageRenderer(size: .init(width: 500, height: 500)).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
