//
//  SubscriptionTypes.swift
//  founder-wish
//
//  Created by Balu on 11/16/25.
//

import Foundation

public enum SubscriptionTier: String, Sendable {
    case free = "free"
    case trial = "trial"
    case paid = "paid"
}

public enum BillingCycle: String, Sendable {
    case monthly = "monthly"
    case yearly = "yearly"
    case lifetime = "lifetime"
    case weekly = "weekly"
}

