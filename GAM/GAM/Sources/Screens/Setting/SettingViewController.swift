//
//  SettingViewController.swift
//  GAM
//
//  Created by Juhyeon Byun on 1/15/24.
//

import UIKit
import RxSwift

final class SettingViewController: BaseViewController {
    
    // MARK: Properties
    
    private let viewModel = SettingViewModel()
    private let disposeBag = DisposeBag()

    // MARK: UIComponents
    
    private let tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = .gamGray1
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.sectionHeaderTopPadding = 0
        view.bounces = false
        return view
    }()

    private let navigationView: GamNavigationView = {
        let view = GamNavigationView(type: .backTitle)
        view.setCenterTitle("설정")
        return view
    }()

    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setLayout()
        self.setDelegate()
        self.setBinding()
        self.setBackButtonAction(self.navigationView.backButton)
    }

    // MARK: - Method
    
    private func setupUI() {
        self.hideTabBar()
    }

    private func setDelegate() {
        self.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        self.tableView.rx.setDataSource(self)
            .disposed(by: disposeBag)
        self.tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.className)
    }
    
    private func setBinding() {
        self.viewModel.action.popViewController
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { owner, _ in
                owner.navigationController?.popToRootViewController(animated: true)
                let signInViewController: BaseViewController = SignInViewController()
                signInViewController.modalTransitionStyle = .crossDissolve
                signInViewController.modalPresentationStyle = .fullScreen
                owner.present(signInViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        self.viewModel.action.showNetworkErrorAlert
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { owner, _ in
                owner.showNetworkErrorAlert()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UI

extension SettingViewController {
    private func setLayout() {
        self.view.addSubviews([navigationView, tableView])
        
        self.navigationView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
        }
        
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(navigationView.snp.bottom).inset(1)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDelegate

extension SettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = SettingTableHeaderView()
        headerView.setCategoryLabel(viewModel.categories[section])
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch viewModel.submenus[indexPath.section][indexPath.row] {
        case "문의하기":
            self.sendContactMail()
        case "서비스 소개":
            self.openSafariInApp(url: AppInfo.shared.url.intro)
        case "만든 사람들":
            self.openSafariInApp(url: AppInfo.shared.url.makers)
        case "오픈소스 라이브러리":
            self.openSafariInApp(url: AppInfo.shared.url.openSource)
        case "서비스 이용약관":
            self.openSafariInApp(url: AppInfo.shared.url.agreement)
        case "개인정보처리방침":
            self.openSafariInApp(url: AppInfo.shared.url.privacyPolicy)
        case "로그아웃":
            let alert = UIAlertController(title: nil, message: "접속중인 기기에서\n로그아웃 하시겠습니까?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "로그아웃", style: .default) { _ in
                self.viewModel.action.logout.onNext(())
            }
            alert.addAction(okAction)
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            present(alert, animated: true, completion: nil)
        case "탈퇴하기":
            self.navigationController?.pushViewController(SecessionViewController(viewModel: SecessionViewModel()), animated: true)
        default:
            break
        }
    }
}

// MARK: - UITableViewDataSource

extension SettingViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.categories.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.submenus[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.className, for: indexPath) as? SettingTableViewCell else { return UITableViewCell() }
        cell.setMenuLabel(viewModel.submenus[indexPath.section][indexPath.row])
        return cell
    }
}
