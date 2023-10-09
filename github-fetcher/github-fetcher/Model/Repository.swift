//
//  Repository.swift
//  github-fetcher
//
//  Created by Zhong on 2023/10/8.
//  


import Foundation

struct Repository {
    
    struct Statistic {
        let star: Int
        let watcher: Int
        let fork: Int
        let openIssue: Int
    }
    
    let language: String?
    let name: String
    let description: String?
    let ownerIconPath: String?
    let statistic: Statistic
}

extension Repository: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case owner
        case fullName = "full_name"
        case description
        case language
        case stars = "stargazers_count"
        case watchers = "watchers_count"
        case forks = "forks_count"
        case openIssues = "open_issues_count"
    }
    
    enum OwnerCodingKeys: String, CodingKey {
        case iconPath = "avatar_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let ownerContainer = try container.nestedContainer(keyedBy: OwnerCodingKeys.self, forKey: .owner)
        
        self.language = try container.decodeIfPresent(String.self, forKey: .language)
        self.name = try container.decode(String.self, forKey: .fullName)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.ownerIconPath = try ownerContainer.decodeIfPresent(String.self, forKey: .iconPath)
        self.statistic = .init(
            star: try container.decode(Int.self, forKey: .stars),
            watcher: try container.decode(Int.self, forKey: .watchers),
            fork: try container.decode(Int.self, forKey: .forks),
            openIssue: try container.decode(Int.self, forKey: .openIssues))
    }
}
