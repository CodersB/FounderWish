import XCTest
@testable import FounderWish

final class FounderWishTests: XCTestCase {
    
    // MARK: - Configuration Tests
    
    func testConfiguration() async throws {
        // Test that configuration works
        FounderWish.configure(boardKey: "test-board-key")
        // Configuration is async, so we just verify it doesn't crash
    }
    
    func testConfigurationWithUserInfo() async throws {
        FounderWish.configure(
            boardKey: "test-board-key",
            email: "test@example.com",
            paymentStatus: .paid,
            billingCycle: .monthly,
            amount: "$9.99"
        )
        // Configuration is async, so we just verify it doesn't crash
    }
    
    func testUpdateUser() async throws {
        FounderWish.configure(boardKey: "test-board-key")
        
        // Update email
        FounderWish.set(email: "newemail@example.com")
        
        // Update payment status
        FounderWish.set(paymentStatus: .paid, billingCycle: .yearly, amount: "$99.99")
        
        // Updates are async, so we just verify they don't crash
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
    
    func testPaymentStatus() {
        XCTAssertEqual(PaymentStatus.free.rawValue, "free")
        XCTAssertEqual(PaymentStatus.paid.rawValue, "paid")
        XCTAssertEqual(PaymentStatus.trial.rawValue, "trial")
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
    
    // MARK: - Integration Tests (Requires Environment Variable)
    
    /// Test actual feedback sending to the API
    /// 
    /// This test only runs if FOUNDERWISH_TEST_BOARD_KEY environment variable is set.
    /// To run this test:
    /// 1. Set environment variable: export FOUNDERWISH_TEST_BOARD_KEY="your-test-board-key"
    /// 2. Run: swift test --filter testSendFeedbackIntegration
    /// 
    /// Or in Xcode:
    /// 1. Edit Scheme → Test → Arguments → Environment Variables
    /// 2. Add: FOUNDERWISH_TEST_BOARD_KEY = "your-test-board-key"
    /// 3. Run the test
    func testSendFeedbackIntegration() async throws {
        // Only run if test board key is provided via environment variable
        guard let testBoardKey = ProcessInfo.processInfo.environment["FOUNDERWISH_TEST_BOARD_KEY"],
              !testBoardKey.isEmpty else {
            throw XCTSkip("Skipping integration test: FOUNDERWISH_TEST_BOARD_KEY environment variable not set")
        }
        
        // Configure with test board key
        FounderWish.configure(
            boardKey: testBoardKey,
            email: "test@example.com",
            paymentStatus: .free
        )
        
        // Wait a bit for configuration to complete
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Send a test feedback
        do {
            try await FounderWish.sendFeedback(
                title: "Test Feedback from Unit Test",
                description: "This is an automated test feedback sent at \(Date())",
                source: "ios",
                category: "test"
            )
            // If we get here without throwing, the feedback was sent successfully
            XCTAssertTrue(true, "Feedback sent successfully")
        } catch {
            XCTFail("Failed to send feedback: \(error.localizedDescription)")
        }
    }
    
    /// Test fetching public feedbacks
    /// 
    /// This test only runs if FOUNDERWISH_TEST_BOARD_KEY environment variable is set.
    func testFetchPublicFeedbacksIntegration() async throws {
        // Only run if test board key is provided via environment variable
        guard let testBoardKey = ProcessInfo.processInfo.environment["FOUNDERWISH_TEST_BOARD_KEY"],
              !testBoardKey.isEmpty else {
            throw XCTSkip("Skipping integration test: FOUNDERWISH_TEST_BOARD_KEY environment variable not set")
        }
        
        // Configure with test board key
        FounderWish.configure(boardKey: testBoardKey)
        
        // Wait a bit for configuration to complete
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Fetch public feedbacks
        do {
            let items = try await FounderWish.fetchPublicItems(limit: 10)
            // If we get here without throwing, the fetch was successful
            XCTAssertNotNil(items, "Should receive feedback items (even if empty)")
        } catch {
            XCTFail("Failed to fetch public feedbacks: \(error.localizedDescription)")
        }
    }
}
