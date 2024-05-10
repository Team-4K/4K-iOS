//
//  ProfileInfoView.swift
//  GAM
//
//  Created by Jungbin on 2023/08/01.
//

import UIKit
import SnapKit

final class ProfileInfoView: UIView {
    
    // MARK: Properties
    private let detailPlaceholder = "경험 위주 자기소개 부탁드립니다."
    
    enum ViewType {
        case userProfile
        case myProfile
        case editProfile
    }
    
    // MARK: UIComponents
    
    let infoTextField: UITextField = {
        let textField: UITextField = UITextField()
        textField.textColor = .gamBlack
        textField.font = .subhead4Bold
        return textField
    }()
    
    private let underlineView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .gamGray2
        return view
    }()
    
    let detailTextView: UITextView = {
        let textView: UITextView = UITextView()
        textView.textContainerInset = .zero
        textView.contentInset = .zero
        return textView
    }()
    
    // MARK: Initializer
    
    init(isEditable: Bool) {
        super.init(frame: .zero)
        
        self.setUI(isEditable: isEditable)
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Methods
    
    func setData(type: ViewType, info: String, detail: String) {
        self.infoTextField.text = info
        
        if detail.isEmpty {
            if type != .userProfile {
                self.detailTextView.setTextWithStyle(to: detailPlaceholder, style: .caption2Regular, color: .gamGray3)
            }
        } else {
            self.detailTextView.setTextWithStyle(to: detail, style: .caption2Regular, color: .gamBlack)
        }
    }
    
    private func setUI(isEditable: Bool) {
        self.backgroundColor = .gamWhite
        self.layer.borderColor = UIColor.gamRed.cgColor
        self.makeRounded(cornerRadius: 8)
        if !isEditable {
            self.infoTextField.isUserInteractionEnabled = false
            self.detailTextView.isEditable = false
        }
    }
    
    private func setLayout() {
        self.addSubviews([infoTextField, underlineView, detailTextView])
        
        self.infoTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(27)
        }
        
        self.underlineView.snp.makeConstraints { make in
            make.top.equalTo(self.infoTextField.snp.bottom).offset(6)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(0.5)
        }
        
        self.detailTextView.snp.makeConstraints { make in
            make.top.equalTo(self.underlineView.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(11)
            make.bottom.equalToSuperview().inset(24)
        }
    }
}
