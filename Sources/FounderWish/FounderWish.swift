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
    /// 
    /// You can configure everything at once, or just the boardKey first and set other values later.
    /// 
    /// Example (configure everything at once):
    /// ```swift
    /// FounderWish.configure(
    ///     boardKey: "your-board-key",
    ///     email: "user@example.com",
    ///     paymentStatus: .paid,
    ///     billingCycle: .monthly,
    ///     amount: "$9.99"
    /// )
    /// ```
    /// 
    /// Example (configure just the key first):
    /// ```swift
    /// FounderWish.configure(boardKey: "your-board-key")
    /// // Later, set user info:
    /// FounderWish.set(email: "user@example.com", paymentStatus: .paid)
    /// ```
    public static func configure(
        boardKey: String,
        email: String? = nil,
        paymentStatus: PaymentStatus = .free,
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
                subscriptionStatus: paymentStatus.rawValue,
                email: email,
                customMetadata: metadata.isEmpty ? nil : metadata
            )
            
            await FounderWishCore.shared.configure(
                secret: boardKey,
                overrideBaseURL: overrideBaseURL,
                userProfile: profile
            )
        }
    }
    
    // MARK: - Update User Info (Flexible - update what you have)
    
    /// Update user information - Simple API (all parameters optional!)
    /// 
    /// Update any combination of user info. Only provide the values you want to update.
    /// 
    /// Examples:
    /// ```swift
    /// // Update just email
    /// FounderWish.set(email: "new@email.com")
    /// 
    /// // Update payment status (for subscriptions or one-time purchases)
    /// FounderWish.set(paymentStatus: .paid)
    /// 
    /// // Update everything at once
    /// FounderWish.set(
    ///     email: "user@example.com",
    ///     paymentStatus: .paid,
    ///     billingCycle: .monthly,
    ///     amount: "$9.99"
    /// )
    /// 
    /// // For one-time purchases (lifetime/in-app purchases)
    /// FounderWish.set(
    ///     paymentStatus: .paid,
    ///     billingCycle: .lifetime,
    ///     amount: "$49.99"
    /// )
    /// ```
    public static func set(
        email: String? = nil,
        paymentStatus: PaymentStatus? = nil,
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
                subscriptionStatus: paymentStatus.map { .some($0.rawValue) },
                subscriptionExpiresAt: nil,
                customMetadata: metadata.map { .some($0) }
            )
        }
    }
    
    // MARK: - Internal API (Used by views within the module)
    
    internal static func sendFeedback(
        title: String,
        description: String? = nil,
        source: String = "ios",
        category: String = "feature",
        email: String? = nil
    ) async throws {
        try await FeedbackAPI.sendFeedback(
            title: title,
            description: description,
            source: source,
            category: category,
            email: email
        )
    }

    internal static func fetchPublicItems(limit: Int = 50) async throws -> [PublicItem] {
        try await FeedbackAPI.fetchPublicItems(limit: limit)
    }

    @discardableResult
    internal static func upvote(feedbackId: String) async throws -> Int {
        try await FeedbackAPI.upvote(feedbackId: feedbackId)
    }
}
