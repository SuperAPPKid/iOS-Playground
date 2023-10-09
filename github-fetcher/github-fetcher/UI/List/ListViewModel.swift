//
//  ListViewModel.swift
//  github-fetcher
//
//  Created by Zhong on 2023/10/9.
//  

import Foundation
import Combine

class ListViewModel {
    
    var onNavigate: ((Repository) -> Void)?
    
    @Published
    private var items = [Repository]()
    
    var cellViewModelsPub: AnyPublisher<[CellViewModel], Never> {
        return $items
            .map { items in
                return items.map { item in
                    let cellVM = CellViewModel(thumbURL: item.ownerIconPath.flatMap { URL(string: $0) },
                                         name: item.name,
                                         description: item.description)
                    cellVM.onNavigate = { [weak self] in
                        guard let self else { return }
                        self.onNavigate?(item)
                    }
                    return cellVM
                }
            }
            .eraseToAnyPublisher()
    }
    
    func clear() {
        items = []
    }
    
    func search(_ text: String, page: Int = 1) -> AnyPublisher<Void, Error> {
        
        let router = Router.Github.Search(query: text, page: page)
        
        return APIManager.BasicRequest(router)
            .publishDecodable(
                type: Response.Github.Search.self,
                queue: .global()
            )
            .value()
            .map { [weak self] result -> Void in
                guard let self else { return }
                self.items = result.items
            }
            .mapError{ $0 }
            .eraseToAnyPublisher()
    }
    
}

extension ListViewModel {
    
    class CellViewModel {
        @Published
        private(set) var thumbURL: URL?
        
        @Published
        private(set) var name: String?
        
        @Published
        private(set) var description: String?
        
        var onNavigate: (() -> Void)?
        
        init(thumbURL: URL? = nil, name: String?, description: String?) {
            self.thumbURL = thumbURL
            self.name = name
            self.description = description
        }
        
        func navigate() {
            onNavigate?()
        }
    }
    
}

extension ListViewModel: Then {}
