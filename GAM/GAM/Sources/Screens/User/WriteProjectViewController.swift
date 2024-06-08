//
//  WriteProjectViewController.swift
//  GAM
//
//  Created by Jungbin on 2023/08/06.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class WriteProjectViewController: BaseViewController, UINavigationControllerDelegate {
    
    private enum Text {
        static let title = "프로젝트"
        static let image = "대표 이미지"
        static let imageDetail = "1:1 사이즈 규격에 맞춰 사진을 올려 주세요."
        static let projectTitle = "제목"
        static let projectPlaceholder = "프로젝트 제목을 작성해 주세요."
        static let projectInfo = "프로젝트 제목을 입력해 주세요."
        static let projectDetail = "설명"
        static let projectDetailPlaceholder = "프로젝트에 대하여 간단히 설명해 주세요!"
    }
    
    private enum Number {
        static let projectTitleLimit = 18
        static let projectDetailLimit = 150
    }
    
    // MARK: UIComponents
    
    private let navigationView: GamNavigationView = {
        let view: GamNavigationView = GamNavigationView(type: .backTitleSave)
        view.setCenterTitle(Text.title)
        view.saveButton.isEnabled = false
        return view
    }()
    
    private let scrollView: UIScrollView = UIScrollView()
    private let contentView: UIView = UIView()
    
    private let imageTitleLabel: GamStarLabel = GamStarLabel(text: Text.image, font: .subhead4Bold)
    private let imageDetailLabel: GamSingleLineLabel = GamSingleLineLabel(text: Text.imageDetail, font: .caption1Regular, color: .gamGray3)
    private let projectImageView: UIImageView = {
        let imageView: UIImageView = UIImageView()
        imageView.backgroundColor = .gamWhite
        imageView.makeRounded(cornerRadius: 10)
        return imageView
    }()
    private let projectImageUploadButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setImage(.icnUploadImage, for: .normal)
        return button
    }()
    private let projectImageEditButton: UIButton = {
        let button: UIButton = UIButton(type: .system)
        button.setImage(.icnPhoto, for: .normal)
        button.isHidden = true
        return button
    }()
    
    private let projectTitleLabel: GamStarLabel = GamStarLabel(text: Text.projectTitle, font: .subhead4Bold)
    private let projectTitleTextField: GamTextField = {
        let textField: GamTextField = GamTextField(type: .none)
        textField.font = .caption3Medium
        textField.setGamPlaceholder(Text.projectPlaceholder)
        textField.returnKeyType = .done
        return textField
    }()
    private let projectTitleInfoLabel: GamSingleLineLabel = GamSingleLineLabel(text: Text.projectInfo, font: .caption1Regular, color: .gamRed)
    private let projectTitleCountLabel: GamSingleLineLabel = {
        let label: GamSingleLineLabel = GamSingleLineLabel(text: "\(0)/\(Number.projectTitleLimit)", font: .caption1Regular, color: .gamGray3)
        label.textAlignment = .right
        return label
    }()
    
    private let projectDetailLabel: GamSingleLineLabel = GamSingleLineLabel(text: Text.projectDetail, font: .subhead4Bold)
    private let projectDetailTextView: UITextView = {
        let textView: UITextView = UITextView()
        textView.makeRounded(cornerRadius: 8)
        textView.font = .caption3Medium
        textView.textColor = .gamBlack
        textView.contentInset = .zero
        textView.textContainerInset = .init(top: 12, left: 16, bottom: 12, right: 16)
        textView.textContainer.lineFragmentPadding = .zero
        textView.returnKeyType = .done
        return textView
    }()
    private let projectDetailCountLabel: GamSingleLineLabel = {
        let label: GamSingleLineLabel = GamSingleLineLabel(text: "\(0)/\(Number.projectDetailLimit)", font: .caption1Regular, color: .gamGray3)
        label.textAlignment = .right
        return label
    }()
    
    // MARK: Properties
    
    var sendUpdateDelegate: SendUpdateDelegate?
    private let disposeBag: DisposeBag = DisposeBag()
    private let imagePickerController: UIImagePickerController = {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        return imagePickerController
    }()
    private var didKeyboardShow: Bool = false
    
    private var projectData: ProjectEntity = .init(id: .init(), thumbnailImageURL: .init(), title: .init(), detail: .init())
    private var viewType: WriteProjectViewType = .create
    private var isSaveButtonEnable: [Bool] = [false, false] {
        didSet {
            self.navigationView.saveButton.isEnabled = self.isSaveButtonEnable[0]
                && self.isSaveButtonEnable[1]
        }
    }
    
    // MARK: Initializer
    
    init(projectData: ProjectEntity?) {
        super.init(nibName: nil, bundle: nil)
        if let data = projectData {
            self.projectData = data
            self.viewType = .update
        } else {
            self.viewType = .create
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setLayout()
        self.setImagePickerController()
        self.setBackButtonAction(self.navigationView.backButton)
        self.setProjectTitleInfoLabel()
        self.setProjectTitleClearButtonAction()
        self.setProjectDetailTextInfoLabel()
        self.setUploadImageButtonAction()
        self.setDetailTextView()
        self.setSaveButtonAction()
        
        if self.viewType == .update {
            self.setUpdateProjectData()
        }
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
    
    private func setUpdateProjectData() {
        self.projectImageView.setImageUrl(projectData.thumbnailImageURL)
        self.isSaveButtonEnable[0] = true
        self.projectImageUploadButton.isHidden = true
        self.projectImageEditButton.isHidden = false
    
        self.projectTitleTextField.text = projectData.title
        self.projectDetailTextView.setTextWithStyle(to: projectData.detail.isEmpty ? Text.projectDetailPlaceholder : projectData.detail, style: .caption3Medium, color: projectData.detail.isEmpty ? .gamGray3 : .gamBlack)
        
        self.projectTitleTextField.sendActions(for: .editingChanged)
    }
    
    private func setImagePickerController() {
        self.imagePickerController.delegate = self
    }
    
    private func setProjectTitleInfoLabel() {
        self.projectTitleTextField.rx.text
                .orEmpty
                .distinctUntilChanged()
                .asDriver(onErrorJustReturn: "")
                .drive(with: self, onNext: { owner, changedText in
                    owner.projectTitleCountLabel.text = "\(changedText.count)/\(Number.projectTitleLimit)"
                    if changedText.count > 18 {
                        owner.projectTitleTextField.deleteBackward()
                    }
                    let trimText = changedText.trimmingCharacters(in: .whitespaces)
                    owner.isSaveButtonEnable[1] = !trimText.isEmpty
                    if !changedText.isEmpty && trimText.isEmpty {
                        owner.projectTitleInfoLabel.isHidden = false
                        owner.projectTitleTextField.layer.borderWidth = 1
                    } else {
                        owner.projectTitleInfoLabel.isHidden = true
                        owner.projectTitleTextField.layer.borderWidth = 0
                    }
                })
                .disposed(by: disposeBag)
    }
    
    private func setProjectTitleClearButtonAction() {
        self.projectTitleTextField.clearButton.setAction { [weak self] in
            self?.projectTitleCountLabel.text = "\(0)/\(Number.projectTitleLimit)"
            self?.projectTitleInfoLabel.isHidden = false
            self?.projectTitleTextField.layer.borderWidth = 1
            self?.isSaveButtonEnable[1] = false
        }
    }
    
    private func setProjectDetailTextInfoLabel() {
        self.projectDetailTextView.rx.text
            .orEmpty
            .distinctUntilChanged()
            .withUnretained(self)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: { (owner, changedText) in
                owner.projectDetailTextView.text.removeLastSpace()
                if owner.projectDetailTextView.textColor == .gamBlack {
                    if changedText.count > Number.projectDetailLimit {
                        owner.projectDetailTextView.deleteBackward()
                    }
                    self.projectDetailCountLabel.text = "\(changedText.count)/\(Number.projectDetailLimit)"
                }
                
            })
            .disposed(by: self.disposeBag)
    }
    
    private func setUploadImageButtonAction() {
        self.projectImageUploadButton.setAction { [weak self] in
            self?.present(self?.imagePickerController ?? UIViewController(), animated: true)
        }
        
        self.projectImageEditButton.setAction { [weak self] in
            self?.present(self?.imagePickerController ?? UIViewController(), animated: true)
        }
    }
    
    private func setDetailTextView() {
        self.projectDetailTextView.delegate = self
        self.projectDetailTextView.setTextWithStyle(to: Text.projectDetailPlaceholder, style: .caption3Medium, color: .gamGray3)
    }
    
    @objc
    func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let keyboardHeight: CGFloat = keyboardFrame.cgRectValue.height
            let tabBarHeight: CGFloat = self.tabBarController?.tabBar.frame.height ?? 0
            
            if !self.didKeyboardShow {
                self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentOffset.y + keyboardHeight - tabBarHeight), animated: true)
                self.didKeyboardShow = true
            }
        }
    }
    
    @objc
    func keyboardWillHide(_ notification: Notification) {
        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.frame.height), animated: true)
        self.didKeyboardShow = false
    }
    
    private func setAddProjectData(completion: @escaping (String) -> ()) {
        self.getImageUrl() { data in
            self.projectData = .init(
                id: self.projectData.id,
                thumbnailImageURL: String(data.fileName.dropFirst(5)),
                title: self.projectTitleTextField.text ?? "",
                detail: self.projectDetailTextView.text == Text.projectDetailPlaceholder ? "" : self.projectDetailTextView.text
            )
            completion(data.preSignedUrl)
        }
    }
    
    private func setSaveButtonAction() {
        self.navigationView.saveButton.setAction { [weak self] in
            self?.setAddProjectData() { preSignedUrl in
                self?.uploadImage(uploadUrl: preSignedUrl, image: self?.projectImageView.image ?? UIImage()) {
                    if let projectData = self?.projectData {
                        if self?.viewType == .create {
                            self?.createPortfolio(image: projectData.thumbnailImageURL, title: projectData.title, detail: projectData.detail) {
                                self?.sendUpdateDelegate?.sendUpdate(data: true)
                            }
                        } else {
                            self?.updatePortfolio(workId: projectData.id, image: projectData.thumbnailImageURL, title: projectData.title, detail: projectData.detail) {
                                self?.sendUpdateDelegate?.sendUpdate(data: false)
                            }
                        }
                    }
                }
            }
            self?.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

    extension WriteProjectViewController: UIImagePickerControllerDelegate {
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true) {
                if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                    self.projectImageView.image = image
                    self.isSaveButtonEnable[0] = true
                    self.projectImageUploadButton.isHidden = true
                    self.projectImageEditButton.isHidden = false
                }
            }
        }
    }

// MARK: - UITextViewDelegate

extension WriteProjectViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if self.projectDetailTextView.textColor == .gamGray3 {
            self.projectDetailTextView.text = nil
            self.projectDetailTextView.textColor = .gamBlack
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.endEditing(true)
        if self.projectDetailTextView.text.isEmpty {
            self.projectDetailTextView.setTextWithStyle(to: Text.projectDetailPlaceholder, style: .caption3Medium, color: .gamGray3)
        }
    }
}

// MARK: - Network

private extension WriteProjectViewController {
    private func createPortfolio(image: String, title: String, detail: String, completion: @escaping () -> ()) {
        self.startActivityIndicator()
        UserService.shared.createPortfolio(data: CreatePortfolioRequestDTO(image: "/work/" + image, title: title, detail: detail)) { networkResult in
            switch networkResult {
            case .success(_):
                completion()
            default:
                self.showNetworkErrorAlert()
            }
            self.stopActivityIndicator()
        }
    }
    
    private func getImageUrl(completion: @escaping (GetImageUrlResponseDTO) -> ()) {
        self.startActivityIndicator()
        UserService.shared.getImageUrl(data: GetImageUrlRequestDTO(imageName: "gam.jpeg")) { networkResult in
            switch networkResult {
            case .success(let responseData):
                if let result = responseData as? GetImageUrlResponseDTO {
                    completion(result)
                }
            default:
                self.showNetworkErrorAlert()
            }
            self.stopActivityIndicator()
        }
    }
    
    private func uploadImage(uploadUrl: String, image: UIImage, completion: @escaping () -> ()) {
        UserService.shared.uploadImage(data: UploadImageRequestDTO(uploadUrl: uploadUrl, image: image)) {
            completion()
        }
    }
    
    private func updatePortfolio(workId: Int, image: String, title: String, detail: String, completion: @escaping () -> ()) {
        self.startActivityIndicator()
        UserService.shared.updatePortfolio(data: UpdateMyPortfolioRequestDTO(workId: workId, image: "/work/" + image, title: title, detail: detail)) { networkResult in
            switch networkResult {
            case .success(_):
                completion()
            default:
                self.showNetworkErrorAlert()
            }
            self.stopActivityIndicator()
        }
    }
}

// MARK: - UI

extension WriteProjectViewController {
    private func setLayout() {
        self.view.addSubviews([navigationView, scrollView])
        self.scrollView.addSubview(contentView)
        
        self.contentView.addSubviews([
            imageTitleLabel, imageDetailLabel, projectImageView, projectImageUploadButton, projectImageEditButton,
            projectTitleLabel, projectTitleTextField, projectTitleInfoLabel, projectTitleCountLabel,
            projectDetailLabel, projectDetailTextView, projectDetailCountLabel
        ])
        
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
        
        self.imageTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.leading.equalToSuperview().inset(24)
            make.height.equalTo(27)
        }
        
        self.imageDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(self.imageTitleLabel.snp.bottom)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(18)
        }
        
        self.projectImageView.snp.makeConstraints { make in
            make.top.equalTo(self.imageDetailLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(self.projectImageView.snp.width)
        }
        
        self.projectImageUploadButton.snp.makeConstraints { make in
            make.center.equalTo(self.projectImageView)
            make.width.height.equalTo(48)
        }
        
        self.projectImageEditButton.snp.makeConstraints { make in
            make.right.bottom.equalTo(self.projectImageView).inset(10)
            make.width.height.equalTo(40)
        }
        
        self.projectTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.projectImageView.snp.bottom).offset(40)
            make.leading.equalToSuperview().inset(24)
            make.height.equalTo(27)
        }
        
        self.projectTitleTextField.snp.makeConstraints { make in
            make.top.equalTo(self.projectTitleLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(45)
        }
        
        self.projectTitleInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(self.projectTitleTextField.snp.bottom).offset(6)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(18)
        }
        
        self.projectTitleCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(self.projectTitleInfoLabel)
            make.right.equalToSuperview().inset(24)
            make.height.equalTo(18)
        }
        
        self.projectDetailLabel.snp.makeConstraints { make in
            make.top.equalTo(self.projectTitleCountLabel.snp.bottom).offset(28)
            make.leading.equalToSuperview().inset(24)
            make.height.equalTo(27)
        }
        
        self.projectDetailTextView.snp.makeConstraints { make in
            make.top.equalTo(self.projectDetailLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.height.equalTo(141)
        }
        
        self.projectDetailCountLabel.snp.makeConstraints { make in
            make.top.equalTo(self.projectDetailTextView.snp.bottom).offset(8)
            make.right.equalToSuperview().inset(24)
            make.height.equalTo(18)
            make.bottom.equalToSuperview().inset(30)
        }
    }
}
