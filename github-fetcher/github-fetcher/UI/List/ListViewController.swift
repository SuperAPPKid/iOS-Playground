//
//  ListViewController.swift
//  github-fetcher
//
//  Created by Zhong on 2023/10/9.
//  

import UIKit
import Combine
import Kingfisher
import SnapKit

class ListViewController: UITableViewController {
    
    private typealias CellViewModel = ListViewModel.CellViewModel
    
    private lazy var cancellables = Set<AnyCancellable>()
    
    private lazy var navigationbarAppearance = (
        regular: UINavigationBarAppearance().then {
            $0.backgroundColor = .darkGray
            $0.titleTextAttributes = [.foregroundColor: UIColor.white]
            $0.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        },
        large: UINavigationBarAppearance().then {
            $0.backgroundColor = .systemGroupedBackground
            $0.titleTextAttributes = [.foregroundColor: UIColor.darkText]
            $0.largeTitleTextAttributes = [.foregroundColor: UIColor.darkText]
        }
    )
    
    private lazy var searchBar = UISearchBar()
    
    private var viewModel: ListViewModel?
    private var cellViewModels = [CellViewModel]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        definesPresentationContext = true
        
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.title = "Repository Search"
        navigationItem.largeTitleDisplayMode = .always
        
        tableView.keyboardDismissMode = .onDrag
        tableView.refreshControl = UIRefreshControl().then {
            $0.addTarget(self, action: #selector(onRefreshControlValueChanged(_:)), for: .valueChanged)
        }
        tableView.dataSource = self
        
        searchBar.delegate = self
        searchBar.searchTextField.delegate = self
        searchBar.sizeToFit()
        tableView.tableHeaderView = searchBar
        
        Optional.Publisher(navigationController as? NavigationController)
            .flatMap { $0.$isLargeBar }
            .sink { [weak self] isLargeBar in
                guard let self else { return }
                
                if isLargeBar {
                    self.navigationController?.navigationBar.do {
                        $0.standardAppearance = self.navigationbarAppearance.large
                        $0.scrollEdgeAppearance = self.navigationbarAppearance.large
                    }
                } else {
                    self.navigationController?.navigationBar.do {
                        $0.standardAppearance = self.navigationbarAppearance.regular
                        $0.scrollEdgeAppearance = self.navigationbarAppearance.regular
                    }
                }
            }
            .store(in: &cancellables)
            
    }
    
    func bind(viewModel: ListViewModel?) {
        
        guard viewModel !== self.viewModel else { return }
        
        cancellables.removeAll()
        
        self.viewModel = viewModel
        
        guard let viewModel = viewModel else { return }
        
        viewModel.cellViewModelsPub
            .receive(on: OperationQueue.main)
            .sink { [weak self] cellVMs in
                guard let self else { return }
                self.cellViewModels = cellVMs
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func alert(title: String, message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let confirmAct = UIAlertAction(title: "OK", style: .default)
        alertVC.addAction(confirmAct)
        present(alertVC, animated: true)
    }
    
    private func search(_ completion: (() -> Void)? = nil) {
        
        guard let viewModel = viewModel else {
            completion?()
            return
        }
        
        guard let text = searchBar.text, !text.isEmpty else {
            completion?()
            alert(title: "oops!", message: "Please input search text.")
            return
        }
        
        var tmpCancellable: AnyCancellable?
        tmpCancellable = viewModel.search(text)
            .receive(on: OperationQueue.main)
            .sink(receiveCompletion: { result in
                defer {
                    tmpCancellable?.cancel()
                    completion?()
                }
                if case .failure(let error) = result {
                    self.alert(title: "Error", message: error.localizedDescription)
                }
            }, receiveValue: {})
        
    }
}

extension ListViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellViewModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell
        
        if let reusedCell = tableView.dequeueReusableCell(withIdentifier: "Cell") {
            cell = reusedCell
        } else {
            cell = Cell(style: .default, reuseIdentifier: "cell")
        }
        
        if let cell = cell as? Cell {
            cell.bind(viewModel: cellViewModels[indexPath.row])
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cellViewModels[indexPath.row].navigate()
    }
    
}

// searchBar's delegate
extension ListViewController: UISearchBarDelegate, UITextFieldDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        search()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel?.clear()
        return true
    }
    
}

// action
private extension ListViewController {
    
    @objc
    func onRefreshControlValueChanged(_ sender: UIRefreshControl) {
        viewModel?.clear()
        search {
            sender.endRefreshing()
        }
    }
    
}

// subViews
extension ListViewController {
    
    private class Cell: UITableViewCell {
        
        private lazy var thumbImageView = UIImageView().then {
            $0.kf.indicatorType = .activity
        }
        
        private lazy var titleLabel = UILabel().then {
            $0.numberOfLines = 2
            $0.font = .boldSystemFont(ofSize: 16)
        }
        
        private lazy var descLabel = UILabel().then {
            $0.numberOfLines = 0
            $0.font = .systemFont(ofSize: 13, weight: .medium)
        }
        
        private lazy var cancellables = Set<AnyCancellable>()
        
        private var viewModel: CellViewModel?
        
        private lazy var thumbImageProcessor = {
            return DownsamplingImageProcessor(size: CGSize(width: 80, height: 80)) |>
            RoundCornerImageProcessor(cornerRadius: 40)
        }()
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            contentView.addSubview(thumbImageView)
            contentView.addSubview(titleLabel)
            contentView.addSubview(descLabel)
            
            thumbImageView.snp.makeConstraints {
                $0.size.equalTo(80)
                $0.left.top.equalToSuperview().offset(15)
                $0.bottom.lessThanOrEqualTo(-10)
            }
            
            titleLabel.snp.makeConstraints {
                $0.top.equalTo(thumbImageView)
                $0.left.equalTo(thumbImageView.snp.right).offset(10)
                $0.right.lessThanOrEqualToSuperview().offset(-20)
            }
            
            descLabel.snp.makeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(10)
                $0.left.equalTo(titleLabel)
                $0.right.lessThanOrEqualToSuperview().offset(-15)
                $0.bottom.lessThanOrEqualTo(-10)
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func bind(viewModel: CellViewModel?) {
            
            guard viewModel !== self.viewModel else { return }
            
            cancellables.removeAll()
            
            self.viewModel = viewModel
            
            guard let viewModel = viewModel else { return }
            
            viewModel.$thumbURL
                .receive(on: OperationQueue.main)
                .sink { [weak self] thumbURL in
                    guard let self else { return }
                    KF.url(thumbURL)
                        .setProcessor(thumbImageProcessor)
                        .fade(duration: 0.25)
                        .set(to: self.thumbImageView)
                }
                .store(in: &cancellables)
            
            viewModel.$name
                .receive(on: OperationQueue.main)
                .sink { [weak self] name in
                    guard let self else { return }
                    self.titleLabel.text = name
                }
                .store(in: &cancellables)
            
            viewModel.$description
                .receive(on: OperationQueue.main)
                .sink { [weak self] desc in
                    guard let self else { return }
                    self.descLabel.text = desc
                }
                .store(in: &cancellables)
        }
        
    }
    
}
