//
//  EditProfileViewController.swift
//  GAM
//
//  Created by Jungbin on 2023/08/05.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class EditProfileViewController: BaseViewController {
    
    private enum Text {
        static let title = "프로필"
        static let nicknameTitle = "닉네임"
        static let infoTitle = "내소개"
        static let tagTitle = "활동 분야"
        static let emailTitle = "이메일"
        static let emailPlaceholder = "이메일 주소를 입력해 주세요."
        static let profileInfo = "한 줄 소개를 입력해 주세요."
        static let tagInfo = "최소 1개 선택해 주세요."
        static let emailInfo = "올바른 이메일을 입력해 주세요."
        static let detailPlaceholder = "경험 위주 자기소개 부탁드립니다."
        static let nicknameAvailable = "사용가능한 닉네임입니다."
        static let nicknameTypeError = "한글, 영문, 숫자만 입력 가능합니다."
        static let nicknameDuplicated = "이미 사용 중인 닉네임입니다."
        static let nicknameBlank = "닉네임을 입력해주세요."
        static let nicknameCheck = "중복확인"
    }
    
    private enum Number {
        static let cellHorizontalSpacing: CGFloat = 16 * 2
        static let cellHeight = 30
    }
    
    // MARK: UIComponents
    
    private let navigationView: GamNavigationView = {
        let view: GamNavigationView = GamNavigationView(type: .backTitleSave)
        view.setCenterTitle(Text.title)
        return view
    }()
    
    private let scrollView: UIScrollView = UIScrollView()
    private let contentView: UIView = UIView()
    
    private let nicknameTitleLabel: GamSingleLineLabel = GamSingleLineLabel(text: Text.nicknameTitle, font: .subhead4Bold)
    
    private var nicknameTextField: GamTextField = {
        let textField: GamTextField = GamTextField(type: .none)
        return textField
    }()
    
    private let nicknameCountLabel: GamSingleLineLabel = {
        let label: GamSingleLineLabel = GamSingleLineLabel(text: "0/15", font: .caption1Regular, color: .gamGray3)
        label.textAlignment = .right
        label.isHidden = true
        return label
    }()
    
    private let nicknameInfoLabel: GamSingleLineLabel = GamSingleLineLabel(text: Text.nicknameAvailable, font: .caption2Regular, color: .gamBlack)
    
    private let nicknameCheckButton: UIButton = {
        let button: UIButton = UIButton()
        button.setTitle(Text.nicknameCheck, for: .normal)
        button.backgroundColor = .gamGray2
        button.titleLabel?.textColor = .gamWhite
        button.makeRounded(cornerRadius: 8)
        button.titleLabel?.font = .body2Medium
        return button
    }()
    
    private let infoTitleLabel: GamSingleLineLabel = GamSingleLineLabel(text: Text.infoTitle, font: .subhead4Bold)
    
    private let profileInfoView: ProfileInfoView = ProfileInfoView(isEditable: true)
    
    private let profileInfoLabel: GamSingleLineLabel = GamSingleLineLabel(text: Text.profileInfo, font: .caption1Regular, color: .gamRed)
    
    private let profileInfoDetailCountLabel: GamSingleLineLabel = {
        let label: GamSingleLineLabel = GamSingleLineLabel(text: "0/150", font: .caption1Regular, color: .gamGray3)
        label.textAlignment = .right
        return label
    }()
    
    private let tagTitleLabel: GamSingleLineLabel = GamSingleLineLabel(text: Text.tagTitle, font: .subhead4Bold)
    
    private let tagCollectionView: TagCollectionView = TagCollectionView(frame: .zero, collectionViewLayout: .init())
    
    private let tagInfoLabel: GamSingleLineLabel = {
        let label: GamSingleLineLabel = GamSingleLineLabel(text: Text.tagInfo, font: .caption1Regular, color: .gamRed)
        label.textAlignment = .right
        return label
    }()
    
    private let emailTitleLabel: GamSingleLineLabel = GamSingleLineLabel(text: Text.emailTitle, font: .subhead4Bold)
    
    private let emailTextField: GamTextField = {
        let textField: GamTextField = GamTextField(type: .email)
        textField.setGamPlaceholder(Text.emailPlaceholder)
        return textField
    }()
    
    private let emailInfoLabel: GamSingleLineLabel = GamSingleLineLabel(text: Text.emailInfo, font: .caption1Regular, color: .gamRed)
    
    // MARK: Properties
    
    var sendUpdateDelegate: SendUpdateDelegate?
    private var keyboardHeight: CGFloat = 0
    private var profile: UserProfileEntity
    private let disposeBag: DisposeBag = DisposeBag()
    private var profileInfoObservation: NSKeyValueObservation?
    private var tagObservation: NSKeyValueObservation?
    private var emailObservation: NSKeyValueObservation?
    private var isSaveButtonEnable: [Bool] = [false, false, false, true] {
        didSet {
            self.navigationView.saveButton.isEnabled = self.isSaveButtonEnable[0]
                && self.isSaveButtonEnable[1]
                && self.isSaveButtonEnable[2]
                && self.isSaveButtonEnable[3]
        }
    }
    
    // MARK: Initializer
    
    init(profile: UserProfileEntity) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.profileInfoObservation?.invalidate()
        self.tagObservation?.invalidate()
        self.emailObservation?.invalidate()
    }
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setLayout()
        self.setTagCollectionView()
        self.setBackButtonAction(self.navigationView.backButton)
        self.setNicknameView()
        self.setEmailTextField()
        self.setSaveButtonAction()
        self.checkSaveButtonEnable()
        self.setData(profile: self.profile)
        self.setProfileInfoView()
        self.profileInfoView.detailTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addKeyboardObserver(willShow: #selector(self.keyboardWillShow(_:)), willHide: #selector(self.keyboardWillHide(_:)))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.removeKeyboardObserver()
    }
    
    // MARK: Methods
    
    private func setTagCollectionView() {
        self.tagCollectionView.delegate = self
        self.tagCollectionView.dataSource = self
        self.tagCollectionView.allowsSelection = true
        self.tagCollectionView.register(cell: TagCollectionViewCell.self)
    }
    
    func setData(profile: UserProfileEntity) {
        self.profile = profile
        self.profileInfoView.setData(
            type: .editProfile,
            info: profile.info,
            detail: profile.infoDetail
        )
        self.tagCollectionView.reloadData()
        
        _ = profile.tags.map { tag in
            self.tagCollectionView.selectItem(at: IndexPath(row: tag.id - 1, section: 0), animated: true, scrollPosition: .init())
            self.collectionView(self.tagCollectionView, didSelectItemAt: IndexPath(row: tag.id, section: 0))
        }
        
        self.emailTextField.text = profile.email
        self.profileInfoDetailCountLabel.text = "\(profile.infoDetail.count)/150"
        
        self.profileInfoLabel.isHidden = profile.info.count != 0
        self.tagInfoLabel.isHidden = profile.tags.count > 0
        self.emailInfoLabel.isHidden = true
    }
    
    @objc
    func keyboardWillShow(_ notification: NSNotification) {
        if emailTextField.isEditing {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                self.keyboardHeight = keyboardRectangle.height
                self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentOffset.y + self.keyboardHeight - 40.adjustedH), animated: true)
            }
        }
    }
    
    @objc
    func keyboardWillHide(_ notification: Notification) {
        if emailTextField.isEditing {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                self.keyboardHeight = keyboardRectangle.height
                self.scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height), animated: true)
            }
        }
    }
    
    private func setNicknameView() {
        self.nicknameInfoLabel.isHidden = true
        self.nicknameTextField.text = self.profile.name
        
        self.nicknameTextField.rx.controlEvent(.allEditingEvents)
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                guard let changedText = owner.nicknameTextField.text?.replacingOccurrences(of: " ", with: "") else { return }
                owner.nicknameTextField.text = changedText
                
                owner.isSaveButtonEnable[3] = owner.profile.name == changedText
                owner.nicknameTextField.font = .caption2Regular
                owner.nicknameTextField.clearButton.isHidden = changedText.isEmpty
                owner.nicknameCountLabel.isHidden = changedText.isEmpty
                owner.nicknameCheckButton.isEnabled = (owner.profile.name != changedText) && (!changedText.isEmpty)

                if owner.nicknameCheckButton.isEnabled {
                    owner.nicknameCheckButton.backgroundColor = .gamBlack
                } else {
                    owner.nicknameCheckButton.backgroundColor = .gamGray2
                }
                
                if changedText.count > 15 {
                    owner.nicknameTextField.deleteBackward()
                } else {
                    owner.nicknameCountLabel.text = "\(changedText.count)/15"
                }
                
                if changedText.isEmpty {
                    owner.nicknameTextField.layer.borderColor = UIColor.gamRed.cgColor
                    owner.nicknameInfoLabel.text = Text.nicknameBlank
                    owner.nicknameInfoLabel.textColor = .gamRed
                    owner.nicknameInfoLabel.isHidden = false
                    owner.nicknameTextField.layer.borderWidth = 1
                } else {
                    owner.nicknameInfoLabel.isHidden = true
                    owner.nicknameTextField.layer.borderWidth = 0
                }
            })
            .disposed(by: disposeBag)
        
        self.nicknameTextField.rx.controlEvent(.editingDidEnd)
            .subscribe(with: self) { owner, _ in
                owner.nicknameCountLabel.isHidden = true
                owner.nicknameTextField.clearButton.isHidden = true
            }
            .disposed(by: disposeBag)
        
        self.nicknameTextField.clearButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.nicknameCheckButton.backgroundColor = .gamGray2
                owner.nicknameCheckButton.isEnabled = false
            }
            .disposed(by: disposeBag)
        
        self.nicknameCheckButton.rx.tap
            .subscribe(with: self) { owner, _ in
                guard let nickname = owner.nicknameTextField.text else { return }
                
                let regex = "^[ㄱ-ㅎㅏ-ㅣ가-힣a-zA-Z0-9]+$"
                if NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: nickname) {
                    owner.checkUsernameDuplicated(username: nickname) { isDuplicated in
                        if isDuplicated {
                            owner.nicknameTextField.layer.borderColor = UIColor.gamRed.cgColor
                            owner.nicknameInfoLabel.textColor = .gamRed
                            owner.nicknameInfoLabel.text = Text.nicknameDuplicated
                        } else {
                            owner.nicknameTextField.font = .caption3Medium
                            owner.nicknameCheckButton.isEnabled = false
                            owner.nicknameCheckButton.backgroundColor = .gamGray2
                            owner.nicknameTextField.layer.borderColor = UIColor.gamBlack.cgColor
                            owner.nicknameInfoLabel.text = Text.nicknameAvailable
                            owner.nicknameInfoLabel.textColor = .gamBlack
                            owner.isSaveButtonEnable[3] = true
                        }
                    }
                } else {
                    owner.nicknameTextField.layer.borderColor = UIColor.gamRed.cgColor
                    owner.nicknameInfoLabel.textColor = .gamRed
                    owner.nicknameInfoLabel.text = Text.nicknameTypeError
                }
                
                owner.nicknameInfoLabel.isHidden = false
                owner.nicknameTextField.layer.borderWidth = 1
            }
            .disposed(by: disposeBag)
    }
    
    private func setProfileInfoView() {
        self.profileInfoView.infoTextField.rx.text
            .orEmpty
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { (owner, changedText) in
                owner.profile.info = changedText
                owner.profileInfoView.infoTextField.text?.removeLastSpace()
                if changedText.count > 20 {
                    owner.profileInfoView.infoTextField.deleteBackward()
                }
                if changedText.count > 0 {
                    owner.profileInfoView.layer.borderWidth = 0
                    owner.profileInfoLabel.isHidden = true
                } else {
                    owner.profileInfoView.layer.borderWidth = 1
                    owner.profileInfoLabel.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
        self.profileInfoView.detailTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe(onNext: { (owner, changedText) in
                owner.profile.infoDetail = changedText
                owner.profileInfoView.detailTextView.text.removeLastSpace()
                
                if changedText.count > 150 {
                    owner.profileInfoView.detailTextView.deleteBackward()
                } else if changedText == Text.detailPlaceholder {
                    owner.profileInfoDetailCountLabel.text = "0/150"
                } else {
                    owner.profileInfoDetailCountLabel.text = "\(changedText.count)/150"
                }
            })
            .disposed(by: disposeBag)
        
        if profileInfoView.detailTextView.text.count == 0 {
            self.profileInfoView.detailTextView.setTextWithStyle(to: Text.detailPlaceholder, style: .caption2Regular, color: .gamGray3)
        }
    }
    
    private func setEmailTextField() {
        self.emailTextField.rx.observe(String.self, "text")
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { changedText in
                guard let text = changedText else { return }
                self.profile.email = text
                if text.count > 0 {
                    let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                    if NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: changedText) && text.trimmingCharacters(in: .whitespaces).count >= 1 {
                        self.emailInfoLabel.isHidden = true
                    } else {
                        self.emailInfoLabel.isHidden = false
                    }
                } else {
                    self.emailInfoLabel.isHidden = true
                }
        }).disposed(by: disposeBag)
        
        self.emailTextField.clearButton.rx.tap
            .withUnretained(self)
            .bind { (owner, _) in
                owner.emailInfoLabel.isHidden = true
            }
            .disposed(by: disposeBag)
    }
    
    private func setSaveButtonAction() {
        self.navigationView.saveButton.setAction { [weak self] in
            if let profile = self?.profile, let tags = self?.tagCollectionView.indexPathsForSelectedItems?.map({ $0.item + 1 }) {
                guard let userName = self?.nicknameTextField.text else { return }
                let infoDetail = profile.infoDetail == Text.detailPlaceholder ? "" : profile.infoDetail
                self?.updateProfile(userInfo: profile.info, userDetail: infoDetail, email: profile.email, tags: tags, userName: userName) { responseData in
                    self?.sendUpdateDelegate?.sendUpdate(data: responseData)
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    private func checkSaveButtonEnable() {
        self.profileInfoObservation = self.profileInfoLabel.observe(\.isHidden, options: [.old, .new]) { label, change in
            if let isHidden = change.newValue, isHidden != change.oldValue {
                self.isSaveButtonEnable[0] = isHidden
            } else {
                self.isSaveButtonEnable[0] = change.oldValue ?? true
            }
        }
        
        self.tagObservation = self.tagInfoLabel.observe(\.isHidden, options: [.old, .new]) { label, change in
            if let isHidden = change.newValue, isHidden != change.oldValue {
                self.isSaveButtonEnable[1] = isHidden
            } else {
                self.isSaveButtonEnable[1] = change.oldValue ?? true
            }
        }
        
        self.emailObservation = self.emailInfoLabel.observe(\.isHidden, options: [.old, .new]) { label, change in
            if let isHidden = change.newValue, isHidden != change.oldValue {
                self.isSaveButtonEnable[2] = isHidden
            } else {
                self.isSaveButtonEnable[2] = change.oldValue ?? true
            }
        }
    }
}

// MARK: - UITextViewDelegate

extension EditProfileViewController: UITextViewDelegate {    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.profileInfoView.detailTextView.textColor == .gamGray3 {
            self.profileInfoView.detailTextView.text = nil
            self.profileInfoView.detailTextView.textColor = .gamBlack
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.endEditing(true)
        if self.profileInfoView.detailTextView.text.isEmpty {
            self.profileInfoView.detailTextView.setTextWithStyle(to: Text.detailPlaceholder, style: .caption2Regular, color: .gamGray3)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension EditProfileViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Tag.shared.tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.className, for: indexPath) as? TagCollectionViewCell
        else { return UICollectionViewCell() }
        cell.setData(data: Tag.shared.tags[indexPath.row].name)
        if profile.tags.count == 3 {
            cell.isEnable = cell.isSelected
        }
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension EditProfileViewController: UICollectionViewDelegateFlowLayout {
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if self.tagCollectionView.indexPathsForSelectedItems?.count ?? 0 == 3 {
//            for item in 0..<self.tagCollectionView.numberOfItems(inSection: 0) {
//                print(item)
//                let indexPath = IndexPath(item: item, section: 0)
//                guard let cell = self.tagCollectionView.cellForItem(at: indexPath) as? TagCollectionViewCell else { return }
//                
//                print(item, cell.isSelected)
//                if !cell.isSelected {
//                    print("\(item)선택안됨")
//                    cell.isEnable = false
//                }
//            }
//        }
//    }
    
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
        
        if self.tagCollectionView.indexPathsForSelectedItems?.count ?? 0 == 3 {
            for item in 0..<self.tagCollectionView.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                guard let cell = self.tagCollectionView.cellForItem(at: indexPath) as? TagCollectionViewCell else { return }
                
                cell.isEnable = cell.isSelected
            }
        }

        self.tagInfoLabel.isHidden = self.tagCollectionView.indexPathsForSelectedItems?.count ?? 0 > 0
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
        
        self.tagInfoLabel.isHidden = self.tagCollectionView.indexPathsForSelectedItems?.count ?? 0 > 0
    }
}

// MARK: - Network

private extension EditProfileViewController {
    private func checkUsernameDuplicated(username: String, completion: @escaping (Bool) -> ()) {
        self.startActivityIndicator()
        UserService.shared.checkUsernameDuplicated(data: username) { networkResult in
            switch networkResult {
            case .success(let responseData):
                if let result = responseData as? CheckUsernameDuplicatedResponseDTO {
                    completion(result.isDuplicated)
                }
            default:
                self.showNetworkErrorAlert()
            }
            self.stopActivityIndicator()
        }
    }
    
    private func updateProfile(userInfo: String, userDetail: String, email: String, tags: [Int], userName: String, completion: @escaping (UserProfileEntity) -> ()) {
        self.startActivityIndicator()
        UserService.shared.updateProfile(data: UpdateMyProfileRequestDTO(userInfo: userInfo, userDetail: userDetail, email: email, tags: tags, userName: userName)) { networkResult in
            switch networkResult {
            case .success(let responseData):
                if let result = responseData as? UpdateProfileResponseDTO {
                    completion(result.toUserProfileEntity())
                }
            default:
                self.showNetworkErrorAlert()
            }
            self.stopActivityIndicator()
        }
    }
}

// MARK: - UI

extension EditProfileViewController {
    private func setLayout() {
        self.view.addSubviews([navigationView, scrollView])
        self.scrollView.addSubview(contentView)
        self.contentView.addSubviews([nicknameTitleLabel, nicknameTextField, nicknameCountLabel, nicknameCheckButton, nicknameInfoLabel, infoTitleLabel, profileInfoView, tagTitleLabel, tagCollectionView, emailTitleLabel, emailTextField, profileInfoLabel, tagInfoLabel, emailInfoLabel, profileInfoDetailCountLabel])
        
        self.navigationView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
        }
        
        self.scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.navigationView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
        self.contentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        
        self.nicknameTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(26)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(27)
        }
        
        self.nicknameTextField.snp.makeConstraints { make in
            make.top.equalTo(self.nicknameTitleLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalTo(self.nicknameCheckButton.snp.leading).offset(-8)
            make.height.equalTo(44)
        }
        
        self.nicknameCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.nicknameTextField)
            make.trailing.equalTo(self.nicknameTextField).inset(40)
        }
        
        self.nicknameInfoLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.nicknameTextField).offset(4)
            make.top.equalTo(self.nicknameTextField.snp.bottom).offset(6)
        }
        
        self.nicknameCheckButton.snp.makeConstraints { make in
            make.top.equalTo(self.nicknameTextField)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(self.nicknameTextField)
            make.width.equalTo(72)
        }
        
        self.infoTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.nicknameTextField.snp.bottom).offset(38)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(27)
        }
        
        self.profileInfoView.snp.makeConstraints { make in
            make.top.equalTo(self.infoTitleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(194)
        }
        
        self.tagTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.profileInfoView.snp.bottom).offset(44)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(27)
        }
        
        self.tagCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.tagTitleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(156)
        }
        
        self.emailTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.tagCollectionView.snp.bottom).offset(44)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(27)
        }
        
        self.emailTextField.snp.makeConstraints { make in
            make.top.equalTo(self.emailTitleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(56)
        }
        
        self.profileInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(self.profileInfoView.snp.bottom).offset(6)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        
        self.tagInfoLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.tagCollectionView.snp.top).offset(-10)
            make.right.equalToSuperview().inset(24)
        }
        
        self.emailInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(self.emailTextField.snp.bottom).offset(6)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        
        self.profileInfoDetailCountLabel.snp.makeConstraints { make in
            make.top.equalTo(self.profileInfoLabel)
            make.right.equalToSuperview().inset(24)
        }
    }
}
