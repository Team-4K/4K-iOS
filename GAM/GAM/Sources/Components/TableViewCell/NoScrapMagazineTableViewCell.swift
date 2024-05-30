//
//  NoScrapMagazineTableViewCell.swift
//  GAM
//
//  Created by Jungbin on 2023/07/10.
//

import UIKit
import SnapKit

final class NoScrapMagazineTableViewCell: UITableViewCell {
    
    // MARK: UIComponents
    
    private let thumbnailImageView: UIImageView = UIImageView(image: .defaultImage)
    
    private let titleLabel: UILabel = {
        let label: UILabel = UILabel()
        label.numberOfLines = 3
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label: UILabel = UILabel()
        label.font = .caption1Regular
        label.textColor = .gamBlack
        label.numberOfLines = 3
        return label
    }()
    
    let scrapButton: ScrapButton = ScrapButton(type: .system)
    
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
        label.textAlignment = .left
        return label
    }()

    // MARK: Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setUI()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.frame = self.contentView.frame.inset(by: .init(top: 9, left: 20, bottom: 9, right: 20))
    }
    
    private func setUI() {
        self.scrapButton.isHidden = true
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .gamWhite
        self.contentView.makeRounded(cornerRadius: 10)
        self.selectionStyle = .none
    }
    
    func setData(data: MagazineEntity, keyword: String) {
        self.thumbnailImageView.setImageUrl(data.thumbnailImageURL)
        self.titleLabel.setTextWithStyle(to: data.title, style: .caption3Medium, color: .gamBlack)
        self.authorLabel.text = data.author
        self.visibilityCountLabel.text = "\(data.visibilityCount)"
        self.scrapButton.isSelected = data.isScrap
        
        self.highlightKeyword(keyword: keyword)
    }
    
    func setData(data: PortfolioSearchEntity, keyword: String) {
        self.thumbnailImageView.setImageUrl(data.thumbnailImageURL)
        self.titleLabel.setTextWithStyle(to: data.title, style: .caption3Medium, color: .gamBlack)
        self.authorLabel.text = data.author
        self.visibilityStackView.isHidden = true
        
        self.highlightKeyword(keyword: keyword)
    }
    
    private func highlightKeyword(keyword: String) {
        self.titleLabel.setFontColor(to: keyword, font: .caption3Medium, color: .gamRed)
        self.authorLabel.setFontColor(to: keyword, font: .caption1Regular, color: .gamRed)
    }
}

extension NoScrapMagazineTableViewCell {
    private func setLayout() {
        self.visibilityStackView.addArrangedSubviews([visibilityImageView, visibilityCountLabel])
        self.contentView.addSubviews([thumbnailImageView, scrapButton, titleLabel, authorLabel, visibilityStackView])
        
        self.thumbnailImageView.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.height.equalTo(self.thumbnailImageView.snp.width)
        }
        
        self.scrapButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(3)
            make.right.equalToSuperview()
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(14)
            make.left.equalTo(self.thumbnailImageView.snp.right).offset(14)
            make.right.equalTo(self.scrapButton.snp.left).offset(-4)
        }
        
        self.authorLabel.snp.makeConstraints { make in
            make.left.equalTo(self.titleLabel)
            make.bottom.equalToSuperview().inset(10)
        }
        
        self.visibilityStackView.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(12)
            make.centerY.equalTo(self.authorLabel)
        }
        
        self.visibilityCountLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
    }
}
