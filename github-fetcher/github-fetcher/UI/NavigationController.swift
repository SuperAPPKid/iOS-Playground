//
//  NavigationController.swift
//  github-fetcher
//
//  Created by Zhong on 2023/10/9.
//  

import UIKit
import Combine

class NavigationController: UINavigationController {
    
    @Published
    private(set) var isLargeBar: Bool = true
    
    private lazy var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.prefersLargeTitles = true
        
        navigationBar.publisher(for: \.bounds, options: [.new, .initial])
            .receive(on: OperationQueue.main)
            .map { $0.height > 44 }
            .removeDuplicates()
            .sink { [weak self] isLargeBar in
                self?.isLargeBar = isLargeBar
            }.store(in: &cancellables)
    }
    
}
