//
//  TagCollectionViewCell.swift
//  GAM
//
//  Created by Jungbin on 2023/07/07.
//

import UIKit
import SnapKit

final class TagCollectionViewCell: UICollectionViewCell {
    
    // MARK: Properties
    
    let contentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .caption2Regular
        label.textColor = .gamBlack
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            self.updateUI()
        }
    }
    
    var isEnable: Bool = true {
        didSet {
            self.updateUI()
        }
    }
    
    // MARK: Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
        self.setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: Methods
    
    private func setLayout() {
        self.contentView.addSubview(contentLabel)
        self.contentLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setUI() {
        self.contentView.backgroundColor = .clear
        self.contentView.makeRounded(cornerRadius: 4)
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor.gamBlack.cgColor
        self.updateUI()
    }
    
    private func updateUI() {
        if self.isSelected {
            self.contentView.backgroundColor = .gamBlack
            self.contentLabel.textColor = .gamWhite
            self.contentView.layer.borderColor = UIColor.gamBlack.cgColor
        } else {
            if self.isEnable {
                self.contentView.backgroundColor = .clear
                self.contentLabel.textColor = .gamBlack
                self.contentView.layer.borderColor = UIColor.gamBlack.cgColor
            } else {
                self.contentView.backgroundColor = .clear
                self.contentView.layer.borderColor = UIColor.gamGray2.cgColor
                self.contentLabel.textColor = .gamGray2
            }
        }
    }

    func setData(type: TagViewType, data: String) {
        switch type {
        case .filter:
            self.isEnable = true
        case .editProfile:
            self.isEnable = false
        }
        
        self.contentLabel.text = data
    }
    
}
