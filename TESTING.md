# Testing FounderWish

There are two main ways to test this package:

## Option 1: Create a Separate iOS App Project (Recommended for UI Testing)

This is the best way to test the SwiftUI views and see how everything works together.

### Steps:

1. **Open Xcode** and create a new iOS App project:
   - File → New → Project
   - Choose "App" template
   - Name it "FounderWishExample" (or any name you prefer)
   - Make sure "SwiftUI" is selected
   - Save it in a different location than your package

2. **Add the package:**
   - In your new project, go to File → Add Packages...
   - Enter: `https://github.com/CodersB/FounderWish.git`
   - Select the version you want
   - Click "Add Package"

3. **Use the example code:**
   - Copy the code from `ExampleApp.swift` in this package
   - Replace the default `ContentView.swift` with the example code
   - Update the `boardKey` parameter with your actual board key

4. **Run the app:**
   - Build and run on simulator or device
   - Test the feedback form and feedbacks view

### Quick Test Code:

```swift
import SwiftUI
import FounderWish

@main
struct ExampleApp: App {
    init() {
        FounderWish.configure(
            boardKey: "your-board-key",
            email: "test@example.com",
            paymentStatus: .free
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var showFeedbackForm = false
    
    var body: some View {
        Button("Send Feedback") {
            showFeedbackForm = true
        }
        .sheet(isPresented: $showFeedbackForm) {
            FounderWish.FeedbackFormView()
        }
    }
}
```

## Option 2: Unit Tests (For Logic Testing)

The package includes unit tests in `Tests/FounderWishTests/`. These tests include:
- Configuration tests
- Model validation tests
- **Integration tests** (require environment variable)

### To run tests in Xcode:

1. Open the package in Xcode: `open Package.swift`
2. Press `Cmd+U` to run all tests
3. Or use the Test Navigator (Cmd+6) to run individual tests

### Integration Tests (Test Actual API Calls)

The package includes integration tests that actually send feedback to the API. These tests **do not hardcode any secrets** - they use an environment variable instead.

#### Running Integration Tests in Xcode:

1. **Set up environment variable:**
   - Edit Scheme → Test → Arguments → Environment Variables
   - Click the `+` button
   - Name: `FOUNDERWISH_TEST_BOARD_KEY`
   - Value: `your-test-board-key-here` (use a test/development board key)

2. **Run the integration tests:**
   - Press `Cmd+U` to run all tests, or
   - Use Test Navigator (Cmd+6) to run specific tests:
     - `testSendFeedbackIntegration` - Tests sending feedback
     - `testFetchPublicFeedbacksIntegration` - Tests fetching public feedbacks

#### Running Integration Tests from Command Line:

```bash
# Set environment variable
export FOUNDERWISH_TEST_BOARD_KEY="your-test-board-key-here"

# Run specific integration test
swift test --filter testSendFeedbackIntegration
swift test --filter testFetchPublicFeedbacksIntegration

# Note: Command line testing may not work if XCTest is not available
# Use Xcode for the most reliable testing experience
```

#### What the Integration Tests Do:

- **`testSendFeedbackIntegration`**: 
  - Configures FounderWish with your test board key
  - Sends a test feedback to the API
  - Verifies the request succeeds (no errors thrown)

- **`testFetchPublicFeedbacksIntegration`**:
  - Configures FounderWish with your test board key
  - Fetches public feedbacks from the API
  - Verifies the request succeeds

**Note:** If the `FOUNDERWISH_TEST_BOARD_KEY` environment variable is not set, these tests will be skipped automatically (they won't fail).

## Option 3: Manual Testing Script

You can create a simple Swift script to test the API:

```swift
#!/usr/bin/env swift

import Foundation

// This would require importing the package
// For now, use Option 1 (iOS App) for the best testing experience
```

## Testing Checklist

- [ ] Configuration works (`FounderWish.configure`)
- [ ] Feedback form displays correctly
- [ ] Feedback submission works
- [ ] Feedbacks view displays correctly
- [ ] Upvoting works
- [ ] User profile updates work
- [ ] Error handling works (test with invalid board key)

## Tips

- Use a test/development board key when testing
- Test on both iPhone and iPad simulators
- Test with different subscription tiers
- Test error scenarios (no internet, invalid board key, etc.)

