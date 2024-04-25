//
//  SignUpTagViewController.swift
//  GAM
//
//  Created by Jungbin on 2023/07/07.
//

import UIKit
import SnapKit

final class SignUpTagViewController: BaseViewController {
    
    private enum Text {
        static let question = "님,\n\n어떤 분야에서\n활동 중인감?"
        static let guide = "최대 3개 선택"
        static let done = "선택 완료"
    }
    
    private enum Number {
        static let cellHorizontalSpacing: CGFloat = 16 * 2
        static let cellHeight = 30
    }
    
    // MARK: UIComponents
    
    private let progressBarView: GamProgressBarView = GamProgressBarView()
    private let navigationView: GamNavigationView = GamNavigationView(type: .back)
    
    private let questionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 4
        label.font = .headline4Bold
        label.textColor = .gamBlack
        label.textAlignment = .left
        return label
    }()
    
    private let guideLabel: UILabel = {
        let label = UILabel()
        label.text = Text.guide
        label.font = .caption2Regular
        label.textColor = .gamGray3
        label.textAlignment = .left
        return label
    }()
    
    private let tagCollectionView: TagCollectionView = TagCollectionView(frame: .zero, collectionViewLayout: .init())
    
    private let doneButton: GamFullButton = {
        let button: GamFullButton = GamFullButton(type: .system)
        button.setTitle(Text.done, for: .normal)
        button.isEnabled = false
        return button
    }()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUI()
        self.setLayout()
        self.progressBarView.setProgress(step: .second)
        self.setUsername()
        self.setBackButtonAction(self.navigationView.backButton)
        self.setTagCollectionView()
        self.setDoneButtonAction()
    }
    
    // MARK: Methods
    
    private func setUI() {
        self.view.backgroundColor = .gamWhite
    }
    
    private func setUsername() {
        self.questionLabel.text = "\(SignUpInfo.shared.username ?? "")님,\n\n어떤 분야에서\n활동 중인감?"
        self.questionLabel.sizeToFit()
    }
    
    private func setTagCollectionView() {
        self.tagCollectionView.delegate = self
        self.tagCollectionView.dataSource = self
    }
    
    private func setDoneButtonAction() {
        self.doneButton.setAction { [weak self] in
            SignUpInfo.shared.tags = self?.tagCollectionView.indexPathsForSelectedItems?.map({ indexPath in
                indexPath.row + 1
            })
            self?.navigationController?.pushViewController(SignUpInfoViewController(), animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension SignUpTagViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Tag.shared.tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.className, for: indexPath) as? TagCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.setData(data: Tag.shared.tags[indexPath.row].name)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SignUpTagViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizingCell: TagCollectionViewCell = TagCollectionViewCell()
        sizingCell.setData(data: Tag.shared.tags[indexPath.row].name)
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
        
        self.doneButton.isEnabled = self.tagCollectionView.indexPathsForSelectedItems?.count ?? 0 > 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell {
            cell.isSelected = false
        }
        
        self.doneButton.isEnabled = self.tagCollectionView.indexPathsForSelectedItems?.count ?? 0 > 0
    }
}

// MARK: - UI

extension SignUpTagViewController {
    private func setLayout() {
        self.view.addSubviews([progressBarView, navigationView, questionLabel, guideLabel, tagCollectionView, doneButton])
        
        self.progressBarView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(14)
            make.left.right.equalToSuperview()
            make.height.equalTo(2)
        }
        
        self.navigationView.snp.makeConstraints { make in
            make.top.equalTo(self.progressBarView.snp.bottom).offset(14)
            make.horizontalEdges.equalToSuperview()
        }
        
        self.questionLabel.snp.makeConstraints { make in
            make.top.equalTo(self.progressBarView.snp.bottom).offset(75)
            make.left.right.equalToSuperview().inset(20)
        }
        
        self.guideLabel.snp.makeConstraints { make in
            make.top.equalTo(self.questionLabel.snp.bottom).offset(8)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(20)
        }
        
        self.tagCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.guideLabel.snp.bottom).offset(56)
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
