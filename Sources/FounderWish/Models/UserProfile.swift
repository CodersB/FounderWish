//
//  UserProfile.swift
//  founder-wish
//
//  Created by Balu on 11/16/25.
//

import Foundation

struct UserProfile: Sendable {
    let subscriptionStatus: String
    let subscriptionExpiresAt: Date?
    let email: String?
    let customMetadata: [String: String]?
    
    init(
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

