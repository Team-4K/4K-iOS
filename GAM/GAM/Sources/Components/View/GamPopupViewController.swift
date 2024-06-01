//
//  GamPopupViewController.swift
//  GAM
//
//  Created by Jungbin on 1/21/24.
//

import UIKit
import SnapKit

final class GamPopupViewController: BaseViewController {
    
    private enum Text {
        static let magazineTitle = "영감 매거진"
        static let magazineContent = "포트폴리오를 작성해야\n더 많은 매거진을 볼 수 있어요!"
        static let later = "다음에요"
        static let write = "작성할래요"
    }
    
    private enum Number {
        static let radius = 20.0
    }
    
    // MARK: UIComponents
    
    private let backgroundView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .gamWhite
        view.makeRounded(cornerRadius: Number.radius)
        return view
    }()
    
    private let titleLabel: GamSingleLineLabel = {
        let label: GamSingleLineLabel = GamSingleLineLabel(text: Text.magazineTitle, font: .body4Bold)
        label.textAlignment = .center
        return label
    }()
    
    private let contentLabel: GamSingleLineLabel = {
        let label: GamSingleLineLabel = GamSingleLineLabel(text: Text.magazineContent, font: .caption3Medium, color: .gamGray3)
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    private let cancelButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setTitle(Text.later, for: .normal)
        button.setTitleColor(.gamBlack, for: .normal)
        button.titleLabel?.font = .subhead2SemiBold
        button.setBackgroundColor(.gamGray1, for: .normal)
        return button
    }()
    
    let writeButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setTitle(Text.write, for: .normal)
        button.setTitleColor(.gamWhite, for: .normal)
        button.titleLabel?.font = .subhead2SemiBold
        button.setBackgroundColor(.gamBlack, for: .normal)
        return button
    }()
    
    private let horizontalLineView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .gamGray2
        return view
    }()
    
    private let verticalLineView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .gamGray2
        return view
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
        self.setCancelButtonAction()
        self.setWriteButtonAction()
    }
    
    // MARK: Methods
    
    private func setCancelButtonAction() {
        self.cancelButton.setAction { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    private func setWriteButtonAction() {
        self.writeButton.setAction { [weak self] in
            self?.presentingViewController?.tabBarController?.selectedIndex = 3
        }
    }
}

// MARK: - UI

extension GamPopupViewController {
    
    private func setUI() {
        self.view.backgroundColor = .gamBlack.withAlphaComponent(0.4)
    }
    
    private func setLayout() {
        self.view.addSubviews([backgroundView])
        self.backgroundView.addSubviews([titleLabel, contentLabel, cancelButton, writeButton, horizontalLineView, verticalLineView])
        
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
            make.top.equalTo(self.titleLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(48)
        }
        
        self.cancelButton.snp.makeConstraints { make in
            make.top.equalTo(self.contentLabel.snp.bottom).offset(30)
            make.left.bottom.equalToSuperview()
            make.width.equalTo((self.screenWidth - (28 * 2)) / 2)
            make.height.equalTo(56)
        }
        
        self.writeButton.snp.makeConstraints { make in
            make.top.equalTo(self.contentLabel.snp.bottom).offset(30)
            make.right.bottom.equalToSuperview()
            make.width.equalTo((self.screenWidth - (28 * 2)) / 2)
            make.height.equalTo(56)
        }
        
        self.horizontalLineView.snp.makeConstraints { make in
            make.bottom.equalTo(self.cancelButton.snp.top)
            make.horizontalEdges.equalTo(self.backgroundView)
            make.height.equalTo(1)
        }
        
        self.verticalLineView.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.cancelButton)
            make.left.equalTo(self.cancelButton.snp.right)
            make.width.equalTo(1)
        }
    }
}
