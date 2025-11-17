//
//  FounderWishCore.swift
//  founder-wish
//
//  Created by Balu on 11/16/25.
//

import Foundation

@available(iOS 15.0, *)
actor FounderWishCore {
    static let shared = FounderWishCore()
    private static let DEFAULT_BASE_URL = URL(string: "https://indie-wish.vercel.app")!

    private var config: FounderWishConfig?
    private var userProfile: UserProfile?

    func configure(secret: String, overrideBaseURL: URL? = nil, userProfile: UserProfile? = nil) {
        let base = overrideBaseURL ?? Self.DEFAULT_BASE_URL
        self.config = FounderWishConfig(baseURL: base, ingestSecret: secret)
        self.userProfile = userProfile
    }
    
    func mergeUserProfile(
        email: String?? = nil,
        subscriptionStatus: String?? = nil,
        subscriptionExpiresAt: Date?? = nil,
        customMetadata: [String: String]?? = nil
    ) {
        // Merge with existing profile (double optional allows explicit nil setting)
        let current = self.userProfile
        
        // Use double optional unwrapping: nil = don't change, .some(nil) = set to nil, .some(value) = set to value
        let newEmail = email.flatMap { $0 } ?? current?.email
        let newStatus = subscriptionStatus.flatMap { $0 } ?? current?.subscriptionStatus ?? "unknown"
        let newExpires = subscriptionExpiresAt.flatMap { $0 } ?? current?.subscriptionExpiresAt
        let newMetadata = customMetadata.flatMap { $0 } ?? current?.customMetadata
        
        self.userProfile = UserProfile(
            subscriptionStatus: newStatus,
            subscriptionExpiresAt: newExpires,
            email: newEmail,
            customMetadata: newMetadata
        )
    }
    
    func getUserProfile() -> UserProfile? {
        return userProfile
    }

    func currentConfig() throws -> FounderWishConfig {
        guard let c = config else { throw FounderWishError.notConfigured }
        return c
    }

    func updateCachedSlug(_ slug: String) throws {
        guard var c = config else { throw FounderWishError.notConfigured }
        c.cachedSlug = slug
        config = c
    }

    func ensureSlug() async throws -> String {
        if let c = config, let slug = c.cachedSlug { return slug }
        guard let c = config else { throw FounderWishError.notConfigured }

        var req = URLRequest(url: c.baseURL.appendingPathComponent("/api/ingest-info"))
        req.httpMethod = "GET"
        req.addValue(c.ingestSecret, forHTTPHeaderField: "x-ingest-secret")

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Server error"
            throw FounderWishError.server(msg)
        }

        // Try to decode with slug field, fallback to public_id if slug doesn't exist
        struct Info: Decodable {
            let slug: String?
            let public_id: String?
            
            var identifier: String {
                slug ?? public_id ?? ""
            }
        }
        let info = try JSONDecoder().decode(Info.self, from: data)
        let identifier = info.identifier
        guard !identifier.isEmpty else {
            throw FounderWishError.server("API did not return a valid slug or public_id")
        }
        try updateCachedSlug(identifier)
        return identifier
    }
}

