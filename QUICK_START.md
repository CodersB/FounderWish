# Quick Start Guide

## Complete Example

```swift
import SwiftUI
import FounderWish

@main
struct MyApp: App {
    init() {
        // Configure FounderWish
        FounderWish.configure(
            secret: "your-secret-key",
            email: "user@example.com",
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
    @State private var showFeedback = false
    
    var body: some View {
        Button("Send Feedback") {
            showFeedback = true
        }
        .sheet(isPresented: $showFeedback) {
            FounderWish.FeedbackFormView()
        }
    }
}
```

## Adding the Package in Xcode

1. **File → Add Packages...**
2. Enter: `https://github.com/CodersB/FounderWish.git`
3. Select version: "Up to Next Major Version" or specific version
4. Click **"Add Package"**
5. Make sure it's added to your app target

## Verification

If the import works, you should see:
- Autocomplete when typing `FounderWish.`
- The package listed in Project Navigator under "Package Dependencies"

## Still Not Working?

1. **Clean Build Folder:** Shift+Cmd+K
2. **Reset Package Caches:** File → Packages → Reset Package Caches
3. **Restart Xcode**
4. **Check your app's deployment target:** Must be iOS 15.0+ or macOS 12.0+

