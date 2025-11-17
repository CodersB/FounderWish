//
//  FounderWishConfig.swift
//  founder-wish
//
//  Created by Balu on 11/16/25.
//

import Foundation

struct FounderWishConfig: Sendable {
    let baseURL: URL
    let ingestSecret: String
    var cachedSlug: String?

    init(baseURL: URL, ingestSecret: String, cachedSlug: String? = nil) {
        self.baseURL = baseURL
        self.ingestSecret = ingestSecret
        self.cachedSlug = cachedSlug
    }
}

