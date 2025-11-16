//
//  FounderWishError.swift
//  founder-wish
//
//  Created by Balu on 11/16/25.
//

import Foundation

public enum FounderWishError: Error, LocalizedError, Sendable {
    case notConfigured
    case invalidResponse
    case server(String)

    public var errorDescription: String? {
        switch self {
        case .notConfigured:
            "FounderWish is not configured. Call FounderWish.configure(secret:) first."
        case .invalidResponse:
            "Invalid response from server."
        case .server(let msg):
            msg
        }
    }
}

