//
//  API.swift
//  github-fetcher
//
//  Created by Zhong on 2023/10/9.
//

import Alamofire

enum Router {}

// API Domains
extension Router {
    enum Github {}
}

extension Router.Github {
    
    // recommend accept
    static let accept = "application/vnd.github+json"
    
    // GET https://api.github.com/search/repositories
    struct Search: URLRequestConvertible {
        
        let query: String
        let page: Int
        
        func asURLRequest() throws -> URLRequest {
            let path = "https://api.github.com/search/repositories"
            guard let url = URL(string: path) else {
                fatalError("invalid url path: \(path)")
            }
            
            var request = try URLRequest(url: url, method: .get)
            request.headers.add(.accept(Router.Github.accept))
            
            return try URLEncoding.default.encode(request,
                                                  with: [
                                                    "q": query,
                                                    "sort:": "updated",
                                                    "page": page
                                                  ])
        }
        
    }
    
}
