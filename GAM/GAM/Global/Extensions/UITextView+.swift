//
//  UITextView+.swift
//  GAM
//
//  Created by Juhyeon Byun on 3/20/24.
//

import UIKit

extension UITextView {
    
    func setTextWithStyle(to targetString: String, style: UIFont, color: UIColor) {
        let text = targetString
        let attributedString = NSMutableAttributedString(string: text)
        
        attributedString.addAttribute(
            .font,
            value: style,
            range: (text as NSString).range(of: targetString)
        )
        
        attributedString.addAttribute(
            .foregroundColor,
            value: color,
            range: (text as NSString).range(of: targetString)
        )
        
        let paragraphStyle = NSMutableParagraphStyle()
        
        switch style {
        case .headline4Bold:
            paragraphStyle.minimumLineHeight = style.pointSize * 1.3
            paragraphStyle.maximumLineHeight = style.pointSize * 1.3
        default:
            paragraphStyle.minimumLineHeight = style.pointSize * 1.48
            paragraphStyle.maximumLineHeight = style.pointSize * 1.48
        }
        
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length)
        )
        
        switch style {
        case .headline4Bold:
            attributedString.addAttribute(.baselineOffset, value: (style.pointSize * 1.3 - style.lineHeight) / 4, range: NSRange(location: 0, length: attributedString.length))
        default:
            attributedString.addAttribute(.baselineOffset, value: (style.pointSize * 1.48 - style.lineHeight) / 4, range: NSRange(location: 0, length: attributedString.length))
        }
        
        self.attributedText = attributedString
    }
}
