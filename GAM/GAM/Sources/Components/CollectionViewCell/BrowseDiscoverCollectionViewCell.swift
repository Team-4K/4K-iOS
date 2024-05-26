//
//  BrowseDiscoverCollectionViewCell.swift
//  GAM
//
//  Created by Jungbin on 2023/07/16.
//

import UIKit
import SnapKit

final class BrowseDiscoverCollectionViewCell: UICollectionViewCell {
    
    // MARK: UIComponents
    
    private let thumbnailImageView: UIImageView = UIImageView(image: .defaultImage)
    
    private let visibilityStackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let visibilityImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .visibilityGray.withTintColor(.gamWhite)
        return imageView
    }()
    
    private let visibilityCountLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .caption2Regular
        label.textColor = .gamWhite
        label.textAlignment = .left
        return label
    }()
    
    private let titleLabel: GamSingleLineLabel = GamSingleLineLabel(text: "", font: .headline2SemiBold)
    
    private let authorLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .caption3Medium
        label.textColor = .gamBlack
        return label
    }()
    
    let scrapButton: ScrapButton = ScrapButton(type: .system)
    
    private let underlineView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .gamGray1
        return view
    }()
    
    private let authorInfoLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .caption3Medium
        label.textColor = .gamBlack
        return label
    }()
    
    private let tagsLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .caption2Regular
        label.textColor = .gamGray3
        return label
    }()
    
    // MARK: Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.resetData()
    }
    
    // MARK: Methods
    
    private func setUI() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .gamWhite
        self.contentView.makeRounded(cornerRadius: 10)
    }
    
    func setData(data: BrowseDesignerEntity) {
        self.thumbnailImageView.setImageUrl(data.thumbnailImageURL)
        self.titleLabel.text = data.majorProjectTitle
        self.tagsLabel.setTextWithStyle(to: Tag.shared.tagsString(data.tags), style: .caption1Regular, color: .gamGray3)
        self.authorLabel.text = data.name
        self.authorInfoLabel.text = data.info
        self.visibilityCountLabel.text = "\(data.visibilityCount)"
        
        if data.userId == UserInfo.shared.userID {
            self.scrapButton.isHidden = true
        } else {
            self.scrapButton.isSelected = data.isScrap
        }
    }
    
    func resetData() {
        self.thumbnailImageView.image = nil
        self.titleLabel.text = nil
        self.tagsLabel.text = nil
        self.authorLabel.text = nil
        self.authorInfoLabel.text = nil
        self.visibilityCountLabel.text = nil
        self.scrapButton.isHidden = false
        self.scrapButton.isSelected = false
    }
}

// MARK: - UI

extension BrowseDiscoverCollectionViewCell {
    private func setLayout() {
        self.visibilityStackView.addArrangedSubviews([visibilityImageView, visibilityCountLabel])
        
        self.contentView.addSubviews([thumbnailImageView, visibilityStackView, scrapButton, titleLabel, authorLabel, underlineView, authorInfoLabel, tagsLabel])
        
        self.thumbnailImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(327.adjustedH)
        }
        
        self.visibilityStackView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().inset(8)
        }
        
        self.scrapButton.snp.makeConstraints { make in
            make.top.equalTo(self.thumbnailImageView.snp.bottom).offset(16.adjustedH)
            make.right.equalToSuperview().inset(10)
            make.width.height.equalTo(44)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.scrapButton)
            make.left.equalToSuperview().inset(16)
            make.right.equalTo(self.scrapButton.snp.left).offset(-4)
            make.height.equalTo(33.adjustedH)
        }
        
        self.authorLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(16.adjustedH)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(21)
        }
        
        self.underlineView.snp.makeConstraints { make in
            make.top.equalTo(self.authorLabel.snp.bottom).offset(8.adjustedH)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(1)
        }
        
        self.authorInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(self.underlineView.snp.bottom).offset(8.adjustedH)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(21)
        }
        
        self.tagsLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(16.adjustedH)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(21)
        }
    }
}
