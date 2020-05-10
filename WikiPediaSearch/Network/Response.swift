//
//  Response.swift
//  WikiPediaSearch
//
//  Created by Lyine on 2020/05/10.
//  Copyright © 2020 Lyine. All rights reserved.
//

import Foundation

struct WikipediaResponses: Codable {
    let search: String
    let title: [String]
    let description: [String]
    let url: [String]

    init(from decoder: Decoder) throws {
        var unkeyedContainer = try decoder.unkeyedContainer()
        search = try unkeyedContainer.decode(String.self)
        title = try unkeyedContainer.decode([String].self)
        description = try unkeyedContainer.decode([String].self)
        url = try unkeyedContainer.decode([String].self)
    }
}

struct searchResult {
    let title: String
    let url: String
}

extension searchResult {
    static func fetchData(titles:[String],urls:[String]) -> [searchResult] {
        var dictionary: [String:String] = [:]
        
        titles.map {
            dictionary[$0] = ""
        }
        
        dictionary.merge(zip(titles,urls)) { (_, new) in new}
        
        let list = dictionary.map{ (title,url) in
            searchResult.init(title: title, url: url)
        }
        
        return list
    }
}
