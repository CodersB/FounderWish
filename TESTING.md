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
   - Update the `secret` parameter with your actual secret key

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
            secret: "your-secret-key",
            email: "test@example.com",
            subscription: .free
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

The package includes unit tests in `Tests/FounderWishTests/`. However, these require XCTest which may not be available in all Swift Package Manager contexts.

### To run tests in Xcode:

1. Open the package in Xcode: `open Package.swift`
2. Press `Cmd+U` to run tests
3. Or use the Test Navigator (Cmd+6) to run individual tests

### To run tests from command line:

```bash
# This may not work if XCTest is not available
swift test
```

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
- [ ] Error handling works (test with invalid secret)

## Tips

- Use a test/development secret key when testing
- Test on both iPhone and iPad simulators
- Test with different subscription tiers
- Test error scenarios (no internet, invalid secret, etc.)

