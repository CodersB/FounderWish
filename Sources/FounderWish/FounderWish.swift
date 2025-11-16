//
//  FounderWish.swift
//  founder-wish
//
//  Created by Balu on 11/16/25.
//

import Foundation

// MARK: - Public Facade

@available(iOS 15.0, *)
public enum FounderWish: Sendable {
    
    // MARK: - Simple Configuration (Recommended for most apps)
    
    /// Configure FounderWish with user information - Simple API
    /// Example: FounderWish.configure(secret: "key", email: "user@app.com", subscription: .paid, billingCycle: .monthly, amount: "$9.99")
    public static func configure(
        secret: String,
        email: String? = nil,
        subscription: SubscriptionTier = .free,
        billingCycle: BillingCycle? = nil,
        amount: String? = nil,
        overrideBaseURL: URL? = nil
    ) {
        Task.detached {
            var metadata: [String: String] = [:]
            if let cycle = billingCycle {
                metadata["billing_cycle"] = cycle.rawValue
            }
            if let amount = amount {
                metadata["amount"] = amount
            }
            
            let profile = UserProfile(
                subscriptionStatus: subscription.rawValue,
                email: email,
                customMetadata: metadata.isEmpty ? nil : metadata
            )
            
            await FounderWishCore.shared.configure(
                secret: secret,
                overrideBaseURL: overrideBaseURL,
                userProfile: profile
            )
        }
    }
    
    // MARK: - Update User Info (Flexible - update what you have)
    
    /// Update user information - Simple API (all parameters optional!)
    /// Example: FounderWish.updateUser(email: "new@email.com")  // Just email
    /// Example: FounderWish.updateUser(subscription: .premium)  // Just subscription
    /// Example: FounderWish.updateUser(email: "x@y.com", subscription: .paid, billingCycle: .monthly)  // Everything
    public static func updateUser(
        email: String? = nil,
        subscription: SubscriptionTier? = nil,
        billingCycle: BillingCycle? = nil,
        amount: String? = nil
    ) {
        Task.detached {
            var metadata: [String: String]? = nil
            if billingCycle != nil || amount != nil {
                metadata = [:]
                if let cycle = billingCycle {
                    metadata!["billing_cycle"] = cycle.rawValue
                }
                if let amt = amount {
                    metadata!["amount"] = amt
                }
            }
            
            // Merge with existing profile instead of replacing
            await FounderWishCore.shared.mergeUserProfile(
                email: .some(email),
                subscriptionStatus: subscription.map { .some($0.rawValue) },
                subscriptionExpiresAt: nil,
                customMetadata: metadata.map { .some($0) }
            )
        }
    }
    
    /// Update only email (convenience method)
    /// Example: FounderWish.setEmail("user@example.com")
    public static func setEmail(_ email: String?) {
        Task.detached {
            await FounderWishCore.shared.mergeUserProfile(email: .some(email))
        }
    }
    
    /// Update only subscription (convenience method)
    /// Example: FounderWish.setSubscription(.paid, billingCycle: .monthly, amount: "$9.99")
    public static func setSubscription(
        _ tier: SubscriptionTier,
        billingCycle: BillingCycle? = nil,
        amount: String? = nil
    ) {
        updateUser(subscription: tier, billingCycle: billingCycle, amount: amount)
    }
    
    // MARK: - Advanced API (For complex use cases)
    
    /// Advanced: Configure with custom UserProfile
    public static func configureAdvanced(
        secret: String,
        overrideBaseURL: URL? = nil,
        userProfile: UserProfile? = nil
    ) {
        Task.detached {
            await FounderWishCore.shared.configure(
                secret: secret,
                overrideBaseURL: overrideBaseURL,
                userProfile: userProfile
            )
        }
    }
    
    /// Advanced: Update with custom UserProfile
    public static func updateUserProfile(_ profile: UserProfile) {
        Task.detached {
            await FounderWishCore.shared.updateUserProfile(profile)
        }
    }

    public static func isConfigured() async -> Bool {
        await FounderWishCore.shared.isConfigured()
    }

    // MARK: - Feedback API
    
    public static func sendFeedback(
        title: String,
        description: String? = nil,
        source: String = "ios",
        category: String = "feature"
    ) async throws {
        try await FeedbackAPI.sendFeedback(
            title: title,
            description: description,
            source: source,
            category: category
        )
    }

    public static func fetchPublicItems(limit: Int = 50) async throws -> [PublicItem] {
        try await FeedbackAPI.fetchPublicItems(limit: limit)
    }

    @discardableResult
    public static func upvote(feedbackId: String) async throws -> Int {
        try await FeedbackAPI.upvote(feedbackId: feedbackId)
    }
}
