//
//  GamNavigationView.swift
//  GAM
//
//  Created by Jungbin on 2023/07/07.
//

import UIKit
import SnapKit

final class GamNavigationView: UIView {
    
    enum NavigationType {
        case back
        case backTitleShare
        case search
        case searchFilter
        case backUsername
        case backUsernameScrapMore
        case usernameSetting
        case backTitleSave
        case backTitle
    }
    
    enum Text {
        static let saveText = "저장"
    }
    
    // MARK: Properties
    
    private lazy var centerTitleLabel: UILabel = UILabel()
    
    lazy var backButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setImage(.chevronLeft, for: .normal)
        return button
    }()
    
    lazy var shareButton: ShareButton = ShareButton(type: .system)
    lazy var searchButton: SearchButton = SearchButton(type: .system)
    lazy var filterButton: FilterButton = FilterButton(type: .system)
    lazy var moreButton: MoreDefaultButton = MoreDefaultButton(type: .system)
    lazy var scrapButton: ScrapButton = ScrapButton(type: .system)
    lazy var settingButton: SettingButton = SettingButton(type: .system)
    lazy var saveButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = .body4Bold
        button.setTitleColor(.gamBlack, for: .normal)
        button.setTitleColor(.gamGray3, for: .disabled)
        return button
    }()
    
    lazy var headline2Label: GamSingleLineLabel = GamSingleLineLabel(text: "", font: .headline2SemiBold)
    
    lazy var headline4Label: GamSingleLineLabel = GamSingleLineLabel(text: "", font: .headline4Bold)
    
    lazy var underlineView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .gamGray2
        return view
    }()
    
    // MARK: Initializer
    
    init(type: NavigationType) {
        super.init(frame: .zero)
        
        self.setDefaultLayout()
        
        switch type {
        case .back: self.setBackLayout()
        case .backTitleShare: self.setBackTitleShareLayout()
        case .search: self.setSearchLayout()
        case .searchFilter: self.setSearchFilterLayout()
        case .backUsername: self.setBackUsernameLayout()
        case .backUsernameScrapMore: self.setBackUsernameScrapMoreLayout()
        case .usernameSetting: self.setUsernameSettingLayout()
        case .backTitleSave: self.setBackTitleSaveLayout()
        case .backTitle: self.setBackTitleLayout()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Methods
    
    func setCenterTitle(_ text: String) {
        self.centerTitleLabel.setTextWithStyle(to: text, style: .headline2SemiBold, color: .gamBlack)
        self.centerTitleLabel.textAlignment = .center
    }
    
    func setCenterLeftTitle(_ text: String) {
        self.headline2Label.text = text
    }
    
    func setLeftTitle(_ text: String) {
        self.headline4Label.text = text
    }
}

// MARK: - UI

extension GamNavigationView {
    private func setDefaultLayout() {
        self.snp.makeConstraints { make in
            make.height.equalTo(54)
        }
    }
    
    private func setBackLayout() {
        self.addSubviews([backButton])
        
        self.setLeftButtonLayout(button: self.backButton)
    }
    
    private func setBackTitleShareLayout() {
        self.addSubviews([backButton, centerTitleLabel, shareButton])
        
        self.setLeftButtonLayout(button: self.backButton)
        self.setRightButtonLayout(button: self.shareButton)
        self.setCenterTitleLabelLayout()
    }
    
    private func setSearchLayout() {
        self.addSubviews([searchButton])
        
        self.setRightButtonLayout(button: self.searchButton)
    }
    
    private func setSearchFilterLayout() {
        self.addSubviews([searchButton, filterButton])
        
        self.setRightButtonLayout(button: self.searchButton)
        self.filterButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.searchButton)
            make.width.height.equalTo(44)
            make.trailing.equalTo(self.searchButton.snp.leading)
        }
    }
    
    private func setBackUsernameLayout() {
        self.addSubviews([backButton, headline2Label, underlineView])
        
        self.setLeftButtonLayout(button: self.backButton)
        self.headline2Label.snp.makeConstraints { make in
            make.centerY.equalTo(self.backButton)
            make.left.equalTo(self.backButton.snp.right).offset(4)
        }
        self.underlineView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func setBackUsernameScrapMoreLayout() {
        self.addSubviews([backButton, headline2Label, moreButton, scrapButton, underlineView])
        
        self.setLeftButtonLayout(button: self.backButton)
        self.headline2Label.snp.makeConstraints { make in
            make.centerY.equalTo(self.backButton)
            make.left.equalTo(self.backButton.snp.right).offset(4)
        }
        self.setRightButtonLayout(button: self.moreButton)
        self.scrapButton.snp.makeConstraints { make in
            make.centerY.equalTo(self.moreButton)
            make.width.height.equalTo(44)
            make.trailing.equalTo(self.moreButton.snp.leading)
        }
        self.underlineView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func setUsernameSettingLayout() {
        self.addSubviews([headline4Label, settingButton, underlineView])
        
        self.setRightButtonLayout(button: self.settingButton)
        self.headline4Label.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(5)
            make.height.equalTo(34)
            make.left.equalToSuperview().inset(20)
            make.right.equalTo(self.settingButton.snp.left).offset(-8)
        }
        self.underlineView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func setBackTitleSaveLayout() {
        self.addSubviews([backButton, centerTitleLabel, saveButton, underlineView])
        
        self.setLeftButtonLayout(button: self.backButton)
        self.setRightButtonLayout(button: self.saveButton)
        self.setCenterTitleLabelLayout()
        self.underlineView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func setBackTitleLayout() {
        self.addSubviews([backButton, centerTitleLabel, underlineView])
        
        self.setLeftButtonLayout(button: self.backButton)
        self.setCenterTitleLabelLayout()
        self.underlineView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    private func setRightButtonLayout(button: UIButton) {
        button.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview().inset(12)
            make.width.height.equalTo(44)
        }
    }
    
    private func setLeftButtonLayout(button: UIButton) {
        button.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().inset(4)
            make.width.height.equalTo(44)
        }
    }
    
    private func setCenterTitleLabelLayout() {
        self.centerTitleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(6)
            make.centerX.equalToSuperview()
            make.height.equalTo(33)
            make.width.equalToSuperview().multipliedBy(0.68)
        }
    }
}
