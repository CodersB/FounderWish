//
//  UserProfile.swift
//  founder-wish
//
//  Created by Balu on 11/16/25.
//

import Foundation

public struct UserProfile: Sendable {
    public let subscriptionStatus: String
    public let subscriptionExpiresAt: Date?
    public let email: String?
    public let customMetadata: [String: String]?
    
    public init(
        subscriptionStatus: String = "unknown",
        subscriptionExpiresAt: Date? = nil,
        email: String? = nil,
        customMetadata: [String: String]? = nil
    ) {
        self.subscriptionStatus = subscriptionStatus
        self.subscriptionExpiresAt = subscriptionExpiresAt
        self.email = email
        self.customMetadata = customMetadata
    }
}

