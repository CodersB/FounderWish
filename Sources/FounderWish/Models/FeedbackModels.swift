//
//  FeedbackModels.swift
//  founder-wish
//
//  Created by Balu on 11/16/25.
//

import Foundation

private struct FeedbackPayload: Codable, Sendable {
    let title: String
    let description: String?
    let source: String
    let category: String
    
    // Device info
    let app_name: String?
    let app_version: String?
    let os_version: String?
    let device_model: String?
    let device_type: String?
    let lang: String?
    let tz: String?
    let screen_w: Int?
    let screen_h: Int?
    
    // User profile
    let user_identifier: String?
    let subscription_status: String?
    let subscription_expires_at: String?
    let install_date: String?
    let email: String?
    let custom_metadata: [String: String]?
}

public struct PublicItem: Decodable, Sendable {
    public let id: String
    public let title: String
    public let description: String?
    public let status: String
    public let source: String?
    public let created_at: String
    public var votes: Int?
}

struct UpvoteResponse: Decodable, Sendable {
    let ok: Bool
    let votes: Int?
}

