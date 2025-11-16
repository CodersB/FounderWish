import XCTest
@testable import FounderWish

final class FounderWishTests: XCTestCase {
    
    // MARK: - Configuration Tests
    
    func testConfiguration() async throws {
        // Test that configuration works
        FounderWish.configure(secret: "test-secret")
        
        let isConfigured = await FounderWish.isConfigured()
        XCTAssertTrue(isConfigured)
    }
    
    func testConfigurationWithUserInfo() async throws {
        FounderWish.configure(
            secret: "test-secret",
            email: "test@example.com",
            subscription: .paid,
            billingCycle: .monthly,
            amount: "$9.99"
        )
        
        let isConfigured = await FounderWish.isConfigured()
        XCTAssertTrue(isConfigured)
    }
    
    func testUpdateUser() async throws {
        FounderWish.configure(secret: "test-secret")
        
        // Update email
        FounderWish.setEmail("newemail@example.com")
        
        // Update subscription
        FounderWish.setSubscription(.premium, billingCycle: .yearly, amount: "$99.99")
        
        let isConfigured = await FounderWish.isConfigured()
        XCTAssertTrue(isConfigured)
    }
    
    // MARK: - Error Tests
    
    func testFounderWishError() {
        let notConfigured = FounderWishError.notConfigured
        XCTAssertNotNil(notConfigured.errorDescription)
        
        let invalidResponse = FounderWishError.invalidResponse
        XCTAssertNotNil(invalidResponse.errorDescription)
        
        let serverError = FounderWishError.server("Test error")
        XCTAssertEqual(serverError.errorDescription, "Test error")
    }
    
    // MARK: - Model Tests
    
    func testSubscriptionTier() {
        XCTAssertEqual(SubscriptionTier.free.rawValue, "free")
        XCTAssertEqual(SubscriptionTier.paid.rawValue, "paid")
        XCTAssertEqual(SubscriptionTier.premium.rawValue, "premium")
        XCTAssertEqual(SubscriptionTier.trial.rawValue, "trial")
        XCTAssertEqual(SubscriptionTier.unknown.rawValue, "unknown")
    }
    
    func testBillingCycle() {
        XCTAssertEqual(BillingCycle.monthly.rawValue, "monthly")
        XCTAssertEqual(BillingCycle.yearly.rawValue, "yearly")
        XCTAssertEqual(BillingCycle.lifetime.rawValue, "lifetime")
        XCTAssertEqual(BillingCycle.weekly.rawValue, "weekly")
    }
    
    func testUserProfile() {
        let profile = UserProfile(
            subscriptionStatus: "paid",
            subscriptionExpiresAt: Date(),
            email: "test@example.com",
            customMetadata: ["key": "value"]
        )
        
        XCTAssertEqual(profile.subscriptionStatus, "paid")
        XCTAssertEqual(profile.email, "test@example.com")
        XCTAssertEqual(profile.customMetadata?["key"], "value")
    }
    
    func testFounderWishConfig() throws {
        let url = URL(string: "https://example.com")!
        let config = FounderWishConfig(
            baseURL: url,
            ingestSecret: "secret",
            cachedSlug: "test-slug"
        )
        
        XCTAssertEqual(config.baseURL, url)
        XCTAssertEqual(config.ingestSecret, "secret")
        XCTAssertEqual(config.cachedSlug, "test-slug")
    }
    
    // MARK: - PublicItem Tests
    
    func testPublicItemDecoding() throws {
        let json = """
        {
            "id": "123",
            "title": "Test Feature",
            "description": "Test Description",
            "status": "open",
            "source": "ios",
            "created_at": "2024-01-01T00:00:00Z",
            "votes": 5
        }
        """.data(using: .utf8)!
        
        let item = try JSONDecoder().decode(PublicItem.self, from: json)
        XCTAssertEqual(item.id, "123")
        XCTAssertEqual(item.title, "Test Feature")
        XCTAssertEqual(item.description, "Test Description")
        XCTAssertEqual(item.status, "open")
        XCTAssertEqual(item.votes, 5)
    }
}
