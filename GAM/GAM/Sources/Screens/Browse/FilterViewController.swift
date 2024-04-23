//
//  FilterViewController.swift
//  GAM
//
//  Created by Jungbin on 2023/07/24.
//

import UIKit
import SnapKit

final class FilterViewController: BaseViewController {
    
    private enum Text {
        static let title = "필터"
        static let subTitle = "활동 분야"
        static let heading = "최대 3개 선택"
        static let done = "적용"
    }
    
    private enum Number {
        static let cellHorizontalSpacing: CGFloat = 16 * 2
        static let cellHeight = 30
    }
    
    // MARK: UIComponents
    
    private let titleLabel: Headline1Label = Headline1Label(text: Text.title)
    
    private let closeButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setImage(.icnModalX, for: .normal)
        return button
    }()
    
    private let subTitleLabel: GamSingleLineLabel = GamSingleLineLabel(
        text: Text.subTitle,
        font: .subhead3SemiBold
    )
    
    private let headingLabel: GamSingleLineLabel = GamSingleLineLabel(
        text: Text.heading,
        font: .caption2Regular,
        color: .gamGray3
    )
    
    private let tagCollectionView: TagCollectionView = TagCollectionView(frame: .zero, collectionViewLayout: .init())
    
    private let doneButton: GamFullButton = {
        let button: GamFullButton = GamFullButton(type: .system)
        button.setTitle(Text.done, for: .normal)
        return button
    }()
    
    // MARK: Properties
    
    var sendUpdateDelegate: SendUpdateDelegate?
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setLayout()
        self.setUI()
        self.setCloseButtonAction()
        self.setTagCollectionView()
        self.setDoneButtonAction()
    }
    
    // MARK: Methods
    
    private func setUI() {
        self.view.backgroundColor = .gamWhite
    }
    
    private func setCloseButtonAction() {
        self.closeButton.setAction { [weak self] in
            self?.dismiss(animated: true)
        }
    }
    
    private func setTagCollectionView() {
        self.tagCollectionView.delegate = self
        self.tagCollectionView.dataSource = self
    }
    
    private func setDoneButtonAction() {
        self.doneButton.setAction { [weak self] in
            let selectedTagsInt = self?.tagCollectionView.indexPathsForSelectedItems?.map({ indexPath in
                indexPath.row + 1
            })
            let selectedTags = Tag.shared.mapTags(selectedTagsInt ?? [])
            self?.sendUpdateDelegate?.sendUpdate(data: selectedTags)
            self?.dismiss(animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension FilterViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Tag.shared.tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.className, for: indexPath) as? TagCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.setData(type: .filter, data: Tag.shared.tags[indexPath.row].name)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FilterViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizingCell: TagCollectionViewCell = TagCollectionViewCell()
        sizingCell.setData(type: .filter, data: Tag.shared.tags[indexPath.row].name)
        sizingCell.contentLabel.sizeToFit()
        
        let cellWidth = sizingCell.contentLabel.frame.width + Number.cellHorizontalSpacing
        let cellHeight = Number.cellHeight
        return CGSize(width: cellWidth, height: CGFloat(cellHeight))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.tagCollectionView.indexPathsForSelectedItems?.count ?? 0 > 3 {
            collectionView.deselectItem(at: indexPath, animated: true)
        } else {
            if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
                cell.isSelected = true
            }
        }
        
        if self.tagCollectionView.indexPathsForSelectedItems?.count ?? 0 == 3 {
            for item in 0..<self.tagCollectionView.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                guard let cell = self.tagCollectionView.cellForItem(at: indexPath) as? TagCollectionViewCell else { return }
                
                if !cell.isSelected {
                    cell.isEnable = false
                }
            }
        }

        self.doneButton.isEnabled = self.tagCollectionView.indexPathsForSelectedItems?.count ?? 0 > 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
            cell.isSelected = false
        }
        
        for item in 0..<self.tagCollectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            guard let cell = self.tagCollectionView.cellForItem(at: indexPath) as? TagCollectionViewCell else { return }
            
            cell.isEnable = true
        }
    }
}

// MARK: - UI

extension FilterViewController {
    private func setLayout() {
        self.view.addSubviews([titleLabel, closeButton, subTitleLabel, headingLabel, tagCollectionView, doneButton])
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(37)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(30)
        }
        
        self.closeButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(9)
            make.width.height.equalTo(44)
        }
        
        self.subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(30)
            make.left.right.equalTo(self.titleLabel)
            make.height.equalTo(27)
        }
        
        self.headingLabel.snp.makeConstraints { make in
            make.top.equalTo(self.subTitleLabel.snp.bottom).offset(4)
            make.left.right.equalTo(self.titleLabel)
            make.height.equalTo(21)
        }
        
        self.tagCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.headingLabel.snp.bottom).offset(30)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(156)
        }
        
        self.doneButton.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(52)
            make.height.equalTo(48)
        }
    }
}
