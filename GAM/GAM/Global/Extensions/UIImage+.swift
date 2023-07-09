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
    
    static let visibilityBlack: UIImage = (UIImage(named: "visibility_black") ?? UIImage()).withRenderingMode(.alwaysOriginal)
    
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
