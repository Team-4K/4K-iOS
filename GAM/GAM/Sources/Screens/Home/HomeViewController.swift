//
//  HomeViewController.swift
//  GAM
//
//  Created by Jungbin on 2023/06/30.
//

import UIKit

final class HomeViewController: BaseViewController {
    
    enum Text {
        static let magazineTitle = "영감 매거진"
        static let designerTitle = "감잡은 디자이너"
    }
    
    enum Number {
        static let magazineCellHeight = 140
        static let magazineCellSpacing = 18
        static let designerCellHeight = 268.0
        static let designerCellWidth = 180.0
        static let designerCellSpacing = 8.0
    }
    
    // MARK: UIComponents
    
    private let scrollView = UIScrollView()
    
    private let contentView: UIView = UIView()
    private let magazineTitleLabel: Headline1Label = Headline1Label(text: Text.magazineTitle)
    private let magazineTableView: MagazineTableView = MagazineTableView(cellType: .normal)
    private let designerTitleLabel: Headline1Label = Headline1Label(text: Text.designerTitle)
    
    private let designerCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = Number.designerCellSpacing
        flowLayout.itemSize = .init(width: Number.designerCellWidth, height: Number.designerCellHeight)
        
        let collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.layoutMargins = .zero
        collectionView.contentInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        return collectionView
    }()
    
    // MARK: Properties
    
    private var magazines: [MagazineEntity] = []
    private var designers: [PopularDesignerEntity] = []
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTableView()
        self.setCollectionView()
        self.setLayout()
        self.setRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.fetchData()
    }
    
    // MARK: Methods
    
    private func setTableView() {
        self.magazineTableView.delegate = self
        self.magazineTableView.dataSource = self
    }
    
    private func setCollectionView() {
        self.designerCollectionView.delegate = self
        self.designerCollectionView.dataSource = self
        
        self.designerCollectionView.register(cell: PopularDesignerCollectionViewCell.self)
    }
    
    private func setRefreshControl() {
        self.scrollView.refreshControl = UIRefreshControl()
        self.scrollView.refreshControl?.addTarget(target, action: #selector(self.handleRefreshControl), for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        self.fetchData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.scrollView.refreshControl?.endRefreshing()
        }
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.magazines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MagazineTableViewCell.className, for: indexPath) as? MagazineTableViewCell
        else { return UITableViewCell() }
        
        cell.setData(data: self.magazines[indexPath.row])
        cell.scrapButton.removeTarget(nil, action: nil, for: .allTouchEvents)
        cell.scrapButton.setAction { [weak self] in
            if let bool = self?.magazines[indexPath.row].isScrap {
                self?.requestScrapMagazine(data: .init(targetMagazineId: self?.magazines[indexPath.row].id ?? 0, currentScrapStatus: bool)) {
                    cell.scrapButton.isSelected = !bool
                    self?.getPopularMagazine { magazines in
                        self?.magazines = magazines
                        self?.magazineTableView.reloadData()
                    }
                }
            }
        }
        return cell
    }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.designers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PopularDesignerCollectionViewCell.className, for: indexPath) as? PopularDesignerCollectionViewCell
        else { return UICollectionViewCell() }
        
        cell.setData(data: self.designers[indexPath.row])
        cell.scrapButton.removeTarget(nil, action: nil, for: .allTouchEvents)
        cell.scrapButton.setAction { [weak self] in
            if let bool = self?.designers[indexPath.row].isScrap {
                self?.requestScrapDesigner(data: .init(targetUserId: self?.designers[indexPath.row].id ?? 0, currentScrapStatus: bool)) {
                    self?.designers[indexPath.row].isScrap = !bool
                    cell.scrapButton.isSelected = !bool
                }
            }
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let magazineDetailViewController: MagazineDetailViewController = MagazineDetailViewController(url: self.magazines[indexPath.row].url)
        self.navigationController?.pushViewController(magazineDetailViewController, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        self.navigationController?.pushViewController(UserViewController(userID: self.designers[indexPath.row].id), animated: true)
    }
}

// MARK: - Network

extension HomeViewController {
    private func fetchData() {
        self.getPopularMagazine { magazines in
            self.magazines = magazines
            self.magazineTableView.reloadData()
            self.getPopularDesigner { designers in
                self.designers = designers
                self.designerCollectionView.reloadData()
            }
        }
    }
    
    private func getPopularMagazine(completion: @escaping ([MagazineEntity]) -> ()) {
        self.startActivityIndicator()
        MagazineService.shared.getPopularMagazine { networkResult in
            switch networkResult {
            case .success(let responseData):
                if let result = responseData as? MagazineResponseDTO {
                    completion(result.toMagazineEntity())
                }
            default:
                self.showNetworkErrorAlert()
            }
            self.stopActivityIndicator()
        }
    }
    
    private func getPopularDesigner(completion: @escaping ([PopularDesignerEntity]) -> ()) {
        self.startActivityIndicator()
        UserService.shared.getPopularDesigner { networkResult in
            switch networkResult {
            case .success(let responseData):
                if let result = responseData as? PopularDesignerResponseDTO {
                    completion(result.toPopularDesignerEntity())
                }
            default:
                self.showNetworkErrorAlert()
            }
            self.stopActivityIndicator()
        }
    }
}

// MARK: - UI

extension HomeViewController {
    private func setLayout() {
        self.view.addSubviews([scrollView])
        self.scrollView.addSubviews([contentView])
        self.contentView.addSubviews([magazineTitleLabel, magazineTableView, designerTitleLabel, designerCollectionView])
        
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.contentView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        
        self.magazineTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(26)
            make.horizontalEdges.equalToSuperview().inset(22)
            make.height.equalTo(30)
        }
        
        self.magazineTableView.snp.makeConstraints { make in
            make.top.equalTo(self.magazineTitleLabel.snp.bottom).offset(7)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(Number.magazineCellHeight * 3 + Number.magazineCellSpacing * 3)
        }
        
        self.designerTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.magazineTableView.snp.bottom).offset(31)
            make.horizontalEdges.equalToSuperview().inset(22)
            make.height.equalTo(30)
        }
        
        self.designerCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.designerTitleLabel.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(Number.designerCellHeight)
            make.bottom.equalToSuperview().inset(29)
        }
    }
}
