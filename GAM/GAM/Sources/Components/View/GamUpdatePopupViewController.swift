//
//  GamUpdatePopupViewController.swift
//  GAM
//
//  Created by Jungbin on 1/23/24.
//

import UIKit
import SnapKit

final class GamUpdatePopupViewController: BaseViewController {
    
    private enum Text {
        static let title = "새로운 버전 업데이트"
        static let content = "감자들의 의견을 반영하여 사용성을 개선했어요.\n지금 바로 업데이트하고 즐겨 보세요!"
        static let update = "업데이트하러 가기"
    }
    
    private enum Number {
        static let radius = 16.0
        static let buttonRadius = 4.0
    }
    
    // MARK: UIComponents
    
    private let backgroundView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .gamWhite
        view.makeRounded(cornerRadius: Number.radius)
        return view
    }()
    
    private let titleLabel: GamSingleLineLabel = {
        let label: GamSingleLineLabel = GamSingleLineLabel(text: Text.title, font: .body4Bold)
        label.textAlignment = .center
        return label
    }()
    
    private let contentLabel: GamSingleLineLabel = {
        let label: GamSingleLineLabel = GamSingleLineLabel(text: Text.content, font: .caption3Medium, color: .gamGray3)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    let updateButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setTitle(Text.update, for: .normal)
        button.setTitleColor(.gamWhite, for: .normal)
        button.titleLabel?.font = .subhead2SemiBold
        button.setBackgroundColor(.gamBlack, for: .normal)
        button.makeRounded(cornerRadius: Number.buttonRadius)
        return button
    }()
    
    // MARK: Initializer
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overFullScreen
        self.modalTransitionStyle = .crossDissolve
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setLayout()
        self.setUI()
        self.setUpdateButtonAction()
    }
    
    // MARK: Methods
    
    private func setUpdateButtonAction() {
        self.updateButton.setAction {
            if let url = URL(string: "itms-apps://itunes.apple.com/app/\(AppInfo.shared.appID)"),
               UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
}

// MARK: - UI

extension GamUpdatePopupViewController {
    
    private func setUI() {
        self.view.backgroundColor = .gamBlack.withAlphaComponent(0.4)
    }
    
    private func setLayout() {
        self.view.addSubviews([backgroundView])
        self.backgroundView.addSubviews([titleLabel, contentLabel, updateButton])
        
        self.backgroundView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(28)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(36)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(24)
        }
        
        self.contentLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        
        self.updateButton.snp.makeConstraints { make in
            make.top.equalTo(self.contentLabel.snp.bottom).offset(20)
            make.bottom.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
    }
}
