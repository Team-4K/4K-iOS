//
//  MyViewController.swift
//  GAM
//
//  Created by Jungbin on 2023/07/01.
//

import UIKit
import SnapKit
import RxSwift

final class MyViewController: BaseViewController {
    
    private enum Number {
        static let headerHeight = 42.0
        static let headerViewHorizontalInset = 20.0
    }
    
    // MARK: UIComponents
    
    private let navigationView: GamNavigationView = GamNavigationView(type: .usernameSetting)
    private let tabHeaderView: PagingTabHeaderView = PagingTabHeaderView()
    private let scrollView: UIScrollView = UIScrollView()
    
    private let stackView: UIStackView = {
        let stackView: UIStackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    
    // MARK: Properties
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    private var items = ["포트폴리오", "프로필"]
        .enumerated()
        .map { index, str in HeaderItemType(title: str, isSelected: index == 0) }
    
    private var lastSelectedIndex: Int {
        items.firstIndex(where: { $0.isSelected }) ?? 0
    }
    
    fileprivate var contentViewControllers = [UIViewController]()
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpViews()
        self.setLayout()
        self.bindTabHeader()
        self.updateUserProfile()
        self.setSettingButtonAction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.showTabBar()
        self.tabHeaderView.collectionView.reloadData()
        self.bindTabHeader()
        
        DispatchQueue.main.async {
            self.tabHeaderView.rx.updateUnderline.onNext(self.lastSelectedIndex)
        }
    }
    
    // MARK: Methods
    
    private func setUpViews() {
        self.pageViewController.delegate = self
        
        self.contentViewControllers = [
            MyPortfolioViewController(superViewController: self),
            MyProfileViewController(superViewController: self)
        ]
        
        self.addChild(pageViewController)
        self.pageViewController.didMove(toParent: self)
        self.pageViewController.setViewControllers([contentViewControllers[0]], direction: .forward, animated: false)
    }
    
    private func setSettingButtonAction() {
        self.navigationView.settingButton.setAction { [weak self] in
            self?.navigationController?.pushViewController(SettingViewController(), animated: true)
        }
    }
    
    private func updateUserProfile() {
        self.getUserProfile() { profile in
            if let myProfileViewController = self.contentViewControllers[1] as? MyProfileViewController {
                myProfileViewController.setData(profile: profile)
            }
            self.navigationView.setLeftTitle(profile.name)
        }
    }
}

// MARK: - Network

extension MyViewController {
    private func getUserProfile(completion: @escaping (UserProfileEntity) -> ()) {
        self.startActivityIndicator()
        UserService.shared.getProfile { networkResult in
            switch networkResult {
            case .success(let responseData):
                if let result = responseData as? GetMyProfileResponseDTO {
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

extension MyViewController {
    private func setLayout() {
        self.view.addSubviews([navigationView, tabHeaderView, scrollView])
        self.scrollView.addSubview(stackView)
        self.stackView.addArrangedSubview(pageViewController.view)
        
        self.navigationView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
        }
        
        self.tabHeaderView.snp.makeConstraints { make in
            make.top.equalTo(self.navigationView.snp.bottom).offset(30)
            make.left.right.equalToSuperview().inset(Number.headerViewHorizontalInset)
            make.height.equalTo(Number.headerHeight)
        }
        
        self.scrollView.snp.makeConstraints { make in
            make.top.equalTo(self.tabHeaderView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.stackView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        
        self.pageViewController.view.snp.makeConstraints { make in
            make.height.equalTo((self.view.safeAreaLayoutGuide.layoutFrame.height) - (54 + Number.headerHeight)).priority(.high)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    private func bindTabHeader() {
        Observable
            .just(self.items)
            .bind(to: self.tabHeaderView.rx.setItems)
            .disposed(by: disposeBag)
        
        self.tabHeaderView.rx.onIndexSelected
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) { ss, newSelectedIndex in
                ss.updatePageView(newSelectedIndex)
                ss.updateTapHeaderCell(newSelectedIndex)
            }
            .disposed(by: disposeBag)
    }
    
    private func updateTapHeaderCell(_ index: Int) {
        guard index != self.lastSelectedIndex else { return }
        self.items[self.lastSelectedIndex].isSelected = false
        self.items[index].isSelected = true
        
        let updateHeaderItemTypes = [
            UpdateHeaderItemType(self.lastSelectedIndex, items[self.lastSelectedIndex]),
            UpdateHeaderItemType(index, items[index])
        ]
        
        self.tabHeaderView.rx.updateUnderline.onNext(index)
        
        Observable
            .just(updateHeaderItemTypes)
            .take(1)
            .filter { !$0.isEmpty }
            .bind(to: self.tabHeaderView.rx.updateCells)
            .disposed(by: disposeBag)
    }
    
    private func updatePageView(_ index: Int) {
        let viewController = self.contentViewControllers[index]
        let direction = self.lastSelectedIndex < index ? UIPageViewController.NavigationDirection.forward : .reverse
        self.pageViewController.setViewControllers([viewController], direction: direction, animated: true)
    }
}

// MARK: - UIPageViewControllerDelegate

extension MyViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        self.updateTabIndex()
    }
    
    private func updateTabIndex() {
        guard let currentIndex = self.items.firstIndex(where: { $0.isSelected })
        else { return }
        self.updateTapHeaderCell(currentIndex)
    }
}
