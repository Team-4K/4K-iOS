//
//  PopularDesignerCollectionViewCell.swift
//  GAM
//
//  Created by Jungbin on 2023/07/09.
//

import UIKit
import SnapKit

final class PopularDesignerCollectionViewCell: UICollectionViewCell {
    
    // MARK: UIComponents
    
    private let thumbnailImageView: UIImageView = UIImageView(image: .defaultImage)
    
    private let titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .caption3Medium
        label.textColor = .gamBlack
        return label
    }()
    
    private let tagsLabel: UILabel = {
        let label: UILabel = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    let scrapButton: UIButton = {
        let button = UIButton()
        button.setImage(.scrapOffWhite, for: .normal)
        button.setImage(.scrapOnWhite, for: .selected)
        return button
    }()
    
    private let underlineView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .gamGray2
        return view
    }()
    
    private let visibilityStackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    private let visibilityImageView: UIImageView = UIImageView(image: .visibilityBlack)
    
    private let visibilityCountLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .caption1Regular
        label.textColor = .gamBlack
        label.textAlignment = .right
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
    
    // MARK: Methods
    
    private func setUI() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .gamWhite
        self.contentView.makeRounded(cornerRadius: 10)
    }
    
    func setData(data: PopularDesignerEntity) {
        self.thumbnailImageView.setImageUrl(data.thumbnailImageURL)
        self.titleLabel.text = data.name
        self.tagsLabel.setTextWithStyle(to: Tag.shared.tagsString(data.tags), style: .caption1Regular, color: .gamGray3)
        self.visibilityCountLabel.text = "\(data.visibilityCount)"
        self.scrapButton.isSelected = data.isScrap
    }
}

extension PopularDesignerCollectionViewCell {
    private func setLayout() {
        self.visibilityStackView.addArrangedSubviews([visibilityImageView, visibilityCountLabel])
        self.contentView.addSubviews([thumbnailImageView, scrapButton, titleLabel, visibilityStackView, underlineView, tagsLabel])
        
        self.thumbnailImageView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.width.equalTo(self.thumbnailImageView.snp.height)
        }
        
        self.scrapButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(3)
            make.right.equalToSuperview()
            make.size.equalTo(44)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.thumbnailImageView.snp.bottom).offset(10)
            make.left.equalToSuperview().inset(12)
            make.height.equalTo(21)
        }
        
        self.visibilityStackView.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleLabel)
            make.right.equalToSuperview().inset(12)
        }
        
        self.underlineView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(4)
            make.height.equalTo(0.5)
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        self.tagsLabel.snp.makeConstraints { make in
            make.top.equalTo(self.underlineView.snp.bottom).offset(6)
            make.horizontalEdges.equalToSuperview().inset(12)
        }
        
        self.visibilityImageView.snp.makeConstraints { make in
            make.width.height.equalTo(24)
        }
        
        self.visibilityCountLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
    }
}
