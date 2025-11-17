//
//  SubscriptionTypes.swift
//  founder-wish
//
//  Created by Balu on 11/16/25.
//

import Foundation

/// Payment status for users - covers both subscriptions and one-time purchases
public enum PaymentStatus: String, Sendable {
    case free = "free"
    case trial = "trial"
    case paid = "paid"
    case premium = "premium"
}

public enum BillingCycle: String, Sendable {
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    case lifetime = "lifetime"
}

