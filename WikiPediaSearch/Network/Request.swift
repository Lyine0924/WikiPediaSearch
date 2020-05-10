//
//  Request.swift
//  WikiPediaSearch
//
//  Created by Lyine on 2020/05/10.
//  Copyright © 2020 Lyine. All rights reserved.
//

import Foundation

public enum RequestType: String {
    case GET, POST
}

protocol APIRequest {
    var method: RequestType { get }
    var baseURL: String { get }
    var parameter: String { get }
}

extension APIRequest {
    func request() -> URLRequest {
        let url = URL(string: baseURL + parameter)!
        var request = URLRequest(url: url)
        let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true)!

        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}

class WikipediaRequest: APIRequest {
    var baseURL = "https://en.wikipedia.org/w/api.php?action=opensearch&limit=10&namespace=0&format=json&search="
    var method = RequestType.GET
    var parameter: String

    init(word: String) {
        parameter = word
    }
}
