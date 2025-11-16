//
//  FounderWishConfig.swift
//  founder-wish
//
//  Created by Balu on 11/16/25.
//

import Foundation

public struct FounderWishConfig: Sendable {
    public let baseURL: URL
    public let ingestSecret: String
    public var cachedSlug: String?

    public init(baseURL: URL, ingestSecret: String, cachedSlug: String? = nil) {
        self.baseURL = baseURL
        self.ingestSecret = ingestSecret
        self.cachedSlug = cachedSlug
    }
}

