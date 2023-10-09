//
//  Response.swift
//  github-fetcher
//
//  Created by Zhong on 2023/10/9.
//  

import Foundation

enum Response {}

extension Response {
    enum Github {}
}

extension Response.Github {
    
    struct Search: Decodable {
        let items: [Repository]
    }
    
}
