//
//  UIViewController+.swift
//  GAM
//
//  Created by Jungbin on 2023/06/30.
//

import UIKit
import SafariServices

extension UIViewController {
    
    /**
     - Description: 화면 터치시 키보드 내리는 Extension
     */
    @objc
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    /**
     - Description: Alert
     */
    /// 확인 버튼 2개, 취소 버튼 1개 ActionSheet 메서드
    func makeTwoAlertWithCancel(
        okTitle: String, okStyle: UIAlertAction.Style = .default,
        secondOkTitle: String, secondOkStyle: UIAlertAction.Style = .default,
        cancelTitle: String = "취소",
        okAction : ((UIAlertAction) -> Void)?, secondOkAction : ((UIAlertAction) -> Void)?,
        cancelAction : ((UIAlertAction) -> Void)? = nil,
        completion : (() -> Void)? = nil
    ) {
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let alertViewController = UIAlertController(
            title: nil, message: nil,
            preferredStyle: .actionSheet
        )
        
        let okAction = UIAlertAction(title: okTitle, style: okStyle, handler: okAction)
        alertViewController.addAction(okAction)
        
        let secondOkAction = UIAlertAction(title: secondOkTitle, style: secondOkStyle, handler: secondOkAction)
        alertViewController.addAction(secondOkAction)
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelAction)
        alertViewController.addAction(cancelAction)
        
        self.present(alertViewController, animated: true, completion: completion)
    }
    
    /// 확인 버튼 1개, 취소 버튼 1개 Alert 메서드
    func makeAlertWithCancel(
        title : String, message : String? = nil,
        okTitle: String, okStyle: UIAlertAction.Style = .default,
        cancelTitle: String = "취소",
        okAction : ((UIAlertAction) -> Void)?, cancelAction : ((UIAlertAction) -> Void)? = nil,
        completion : (() -> Void)? = nil
    ) {
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        let alertViewController = UIAlertController(
            title: title, message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: okTitle, style: okStyle, handler: okAction)
        alertViewController.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelAction)
        alertViewController.addAction(cancelAction)
        
        self.present(alertViewController, animated: true, completion: completion)
    }
    
    /// 확인 버튼 1개, 취소 버튼 1개, textField Alert 메서드
    func makeAlertWithTextField(
        title: String, message: String? = nil,
        placeHolder: String,
        okTitle: String, okStyle: UIAlertAction.Style = .default,
        cancelTitle: String = "취소",
        okAction: ((String) -> Void)?,
        cancelAction: ((UIAlertAction) -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        let alertViewController = UIAlertController(
            title: title, message: message,
            preferredStyle: .alert
        )

        let okAction = UIAlertAction(title: okTitle, style: okStyle) { _ in
            guard let textFieldText = alertViewController.textFields?.first?.text else {
                okAction?("")
                return
            }
            
            okAction?(textFieldText)
        }
        okAction.isEnabled = false
        alertViewController.addAction(okAction)

        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelAction)
        alertViewController.addAction(cancelAction)
        
        alertViewController.addTextField { textField in
            textField.placeholder = placeHolder
            
            textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        }

        self.present(alertViewController, animated: true, completion: completion)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        guard let okAction = (presentedViewController as? UIAlertController)?.actions.first(where: { $0.style == .default }),
              let text = textField.text
        else { return }
        
        okAction.isEnabled = !text.isEmpty
    }
    
    /// 확인 버튼 Alert 메서드
    func makeAlert(
        title : String, message : String? = nil,
        okTitle: String = "확인", okAction : ((UIAlertAction) -> Void)? = nil,
        completion : (() -> Void)? = nil
    ) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        let alertViewController = UIAlertController(
            title: title, message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: okTitle, style: .default, handler: okAction)
        alertViewController.addAction(okAction)
        self.present(alertViewController, animated: true, completion: completion)
    }
    
    func addKeyboardObserver(willShow: Selector, willHide: Selector) {
        NotificationCenter.default.addObserver(
            self,
            selector: willShow,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
          self,
          selector: willHide,
          name: UIResponder.keyboardWillHideNotification,
          object: nil
        )
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nibName
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nibName
        )
    }
    
    func openSafariInApp(url: String) {
        if let url = URL(string: url) {
            let safariViewController = SFSafariViewController(url: url)
            safariViewController.modalPresentationStyle = .pageSheet
            
            self.present(safariViewController, animated: true)
        } else {
            gamPrint(#function, url, "URL String is not available.")
        }
    }
    
    // MARK: - toast message 띄우기
    ///- parameters:
    ///   - message: 화면에 보여질 메시지
    func showToastMessage(type: ToastMessageType) {
        let toastLabel: GamSingleLineLabel = {
            let label: GamSingleLineLabel = GamSingleLineLabel(text: type.text, font: .caption3Medium, color: .gamWhite)
            label.textAlignment = .center
            label.backgroundColor = .gamBlack
            label.alpha = 0.0
            label.layer.cornerRadius = 35 / 2
            label.clipsToBounds = true
            return label
        }()
        
        let sizingWidth = toastLabel.frame.width + 60
        
        let frame = CGRect(
            x: self.view.frame.size.width / 2 - sizingWidth / 2,
            y: 48.adjustedH,
            width: sizingWidth,
            height: 35
        )
        
        toastLabel.frame = frame
        
        self.view.addSubview(toastLabel)
        
        UIView.animate(
            withDuration: 0.2,
            delay: 0.0,
            options: [.curveEaseInOut],
            animations: {
            toastLabel.alpha = 1.0
        }, completion: { _ in
            UIView.animate(
                withDuration: 0.2,
                delay: 1.5,
                options: .curveEaseInOut,
                animations: {
                toastLabel.alpha = 0.0
            }, completion:  { _ in
                toastLabel.removeFromSuperview()
            })
        })
    }
}
