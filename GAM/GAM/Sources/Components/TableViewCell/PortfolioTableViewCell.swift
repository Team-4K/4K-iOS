//
//  PortfolioTableViewCell.swift
//  GAM
//
//  Created by Jungbin on 2023/07/27.
//

import UIKit
import SnapKit

class PortfolioTableViewCell: UITableViewCell {
    
    // MARK: UIComponents
    
    private let thumbnailImageView: UIImageView = UIImageView(image: .defaultImage)
    
    private let titleLabel: GamSingleLineLabel = GamSingleLineLabel(text: "", font: .headline2SemiBold)
    
    private let underlineView: UIView = {
        let view: UIView = UIView()
        view.backgroundColor = .gamGray1
        return view
    }()
    
    private let detailLabel: GamSingleLineLabel = GamSingleLineLabel(text: "", font: .caption3Medium)
    
    let repView: RepView = RepView()
    
    // MARK: Properties
    
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
        
        self.contentView.frame = self.contentView.frame.inset(by: .init(top: 12, left: 20, bottom: 12, right: 20))
    }
    
    func setData(data: ProjectEntity) {
        self.thumbnailImageView.setImageUrl(data.thumbnailImageURL)
        self.titleLabel.text = data.title
        self.detailLabel.setTextWithStyle(to: data.detail, style: .caption3Medium, color: .gamBlack)
        
        self.underlineView.isHidden = data.detail.isEmpty
        
        if data.detail.isEmpty {
            self.detailLabel.snp.updateConstraints { make in
                make.top.equalTo(self.underlineView.snp.bottom).offset(0)
                make.bottom.equalToSuperview().inset(0)
            }
        } else {
            let labelSize = self.detailLabel.sizeThatFits(CGSize(width: self.frame.width, height: CGFloat.greatestFiniteMagnitude))
            self.detailLabel.snp.updateConstraints { make in
                make.height.equalTo(labelSize.height)
            }
        }
    }
    
    private func setUI() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .gamWhite
        self.contentView.makeRounded(cornerRadius: 10)
        self.selectionStyle = .none
        self.titleLabel.adjustsFontSizeToFitWidth = true
        self.detailLabel.numberOfLines = 0
        self.detailLabel.lineBreakMode = .byCharWrapping
        self.thumbnailImageView.backgroundColor = .gamWhite
    }
    
    private func setLayout() {
        self.contentView.addSubviews([self.thumbnailImageView,
                                      self.repView,
                                      self.titleLabel,
                                      self.underlineView,
                                      self.detailLabel])
        
        self.thumbnailImageView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(self.thumbnailImageView.snp.width)
        }
        
        self.repView.snp.makeConstraints { make in
            make.top.equalTo(self.thumbnailImageView.snp.bottom).offset(24)
            make.right.equalToSuperview().inset(16)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(16)
            make.right.equalTo(self.repView.snp.left).offset(-4)
            make.centerY.equalTo(self.repView)
            make.height.equalTo(33)
        }
        
        self.underlineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.equalTo(self.repView.snp.bottom).offset(11)
            make.height.equalTo(1)
        }
        
        self.detailLabel.snp.makeConstraints { make in
            make.top.equalTo(self.underlineView.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(24)
            make.height.equalTo(0)
        }
    }
}
