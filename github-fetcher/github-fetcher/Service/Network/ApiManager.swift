//
//  ApiManager.swift
//  github-fetcher
//
//  Created by Zhong on 2023/10/9.
//  

import Alamofire

enum APIManager {
    
    static func BasicRequest(_ convertible: URLRequestConvertible) -> DataRequest {
        return AF.request(convertible)
            .validate(statusCode: 200..<300)
    }
    
}
