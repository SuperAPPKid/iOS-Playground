//
//  ListViewController.swift
//  github-fetcher
//
//  Created by Zhong on 2023/10/9.
//  

import UIKit
import Combine

class ListViewController: UITableViewController {
    
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
    
    private lazy var searchController = UISearchController().then {
        $0.obscuresBackgroundDuringPresentation = false
        $0.hidesNavigationBarDuringPresentation = false
        $0.searchResultsUpdater = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        view.backgroundColor = .systemGroupedBackground
        
        navigationItem.title = "Respository Search"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.searchController = searchController
        
        refreshControl = UIRefreshControl().then {
            $0.addTarget(self, action: #selector(onRefreshControlValueChanged(_:)), for: .valueChanged)
        }
        
        tableView.dataSource = self
        
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
}

extension ListViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        if let reusedCell = tableView.dequeueReusableCell(withIdentifier: "Cell") {
            cell = reusedCell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        cell.textLabel?.text = "\(indexPath)"
        
        return cell
    }
    
}

extension ListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        print("Update Result")
    }
    
}

// action
private extension ListViewController {
    @objc
    func onRefreshControlValueChanged(_ sender: UIRefreshControl) {
        
    }
}
