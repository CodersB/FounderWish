//
//  FeedbackAPI.swift
//  founder-wish
//
//  Created by Balu on 11/16/25.
//

import Foundation

@available(iOS 15.0, *)
enum FeedbackAPI {
    
    // FeedbackPayload needs to be accessible here
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
    
    static func sendFeedback(
        title: String,
        description: String? = nil,
        source: String = "ios",
        category: String = "feature"
    ) async throws {
        let cfg = try await FounderWishCore.shared.currentConfig()
        let userProfile = await FounderWishCore.shared.getUserProfile()
        let m = await captureDeviceMeta()
        
        // ISO8601 formatter
        let iso8601 = ISO8601DateFormatter()
        iso8601.formatOptions = [.withInternetDateTime]

        let payload = FeedbackPayload(
            title: title,
            description: description,
            source: source,
            category: category,
            app_name: m.app_name,
            app_version: m.app_version,
            os_version: m.os_version,
            device_model: m.device_model,
            device_type: m.device_type,
            lang: m.lang,
            tz: m.timezone,
            screen_w: m.screen_w,
            screen_h: m.screen_h,
            user_identifier: m.user_identifier,
            subscription_status: userProfile?.subscriptionStatus,
            subscription_expires_at: userProfile?.subscriptionExpiresAt.map { iso8601.string(from: $0) },
            install_date: iso8601.string(from: m.install_date),
            email: userProfile?.email,
            custom_metadata: userProfile?.customMetadata
        )

        var req = URLRequest(url: cfg.baseURL.appendingPathComponent("/api/feedback"))
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue(cfg.ingestSecret, forHTTPHeaderField: "x-ingest-secret")
        req.httpBody = try JSONEncoder().encode(payload)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Server error"
            throw FounderWishError.server(msg)
        }
    }

    static func fetchPublicItems(limit: Int = 50) async throws -> [PublicItem] {
        let cfg = try await FounderWishCore.shared.currentConfig()
        let slug = try await FounderWishCore.shared.ensureSlug()

        var url = cfg.baseURL.appendingPathComponent("/api/public-feedback")
        // API expects public_id parameter (slug is the public identifier)
        url.append(queryItems: [URLQueryItem(name: "public_id", value: slug)])

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse else {
            throw FounderWishError.invalidResponse
        }
        
        guard (200..<300).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Server returned status \(http.statusCode)"
            throw FounderWishError.server(msg)
        }

        struct Payload: Decodable { let items: [PublicItem] }
        do {
            return try JSONDecoder().decode(Payload.self, from: data).items
        } catch {
            // If decoding fails, provide more context
            let jsonString = String(data: data, encoding: .utf8) ?? "Unable to decode response"
            throw FounderWishError.server("Failed to decode response: \(error.localizedDescription). Response: \(jsonString.prefix(200))")
        }
    }

    @discardableResult
    static func upvote(feedbackId: String) async throws -> Int {
        let cfg = try await FounderWishCore.shared.currentConfig()

        var req = URLRequest(url: cfg.baseURL.appendingPathComponent("/api/public-upvote"))
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.addValue(cfg.ingestSecret, forHTTPHeaderField: "x-ingest-secret")
        req.httpBody = try JSONSerialization.data(withJSONObject: [
            "feedback_id": feedbackId
        ])

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Server error"
            throw FounderWishError.server(msg)
        }

        let decoded = try JSONDecoder().decode(UpvoteResponse.self, from: data)
        guard decoded.ok, let votes = decoded.votes else {
            throw FounderWishError.invalidResponse
        }
        return votes
    }
}

