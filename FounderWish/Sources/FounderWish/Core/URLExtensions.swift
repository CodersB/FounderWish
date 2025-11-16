//
//  URLExtensions.swift
//  founder-wish
//
//  Created by Balu on 11/16/25.
//

import Foundation

extension URL {
    mutating func append(queryItems: [URLQueryItem]) {
        var comps = URLComponents(url: self, resolvingAgainstBaseURL: false) ?? URLComponents()
        comps.queryItems = (comps.queryItems ?? []) + queryItems
        if let url = comps.url { self = url }
    }
}

