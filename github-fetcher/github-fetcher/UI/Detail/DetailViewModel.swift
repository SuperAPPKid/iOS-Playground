//
//  DetailViewModel.swift
//  github-fetcher
//
//  Created by Zhong on 2023/10/10.
//  

import Foundation
import Combine

class DetailViewModel {
    
    let repository: Repository
    
    var viewInfoPub: AnyPublisher<ViewInformation, Never> {
        return Just(
            ViewInformation(imageURL: repository.ownerIconPath.flatMap { URL(string: $0) },
                            name: repository.name,
                            description: repository.description,
                            language: repository.language,
                            stars: repository.statistic.star,
                            watchers: repository.statistic.watcher,
                            forks: repository.statistic.fork,
                            issues: repository.statistic.openIssue)
        ).eraseToAnyPublisher()
    }
    
    init(repository: Repository) {
        self.repository = repository
    }
    
}

extension DetailViewModel {
    
    struct ViewInformation {
        let imageURL: URL?
        let name: String
        let description: String?
        let language: String?
        let stars: Int
        let watchers: Int
        let forks: Int
        let issues: Int
    }
    
}
