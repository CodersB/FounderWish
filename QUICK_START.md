# Quick Start Guide

## Complete Example

```swift
import SwiftUI
import FounderWish

@main
struct MyApp: App {
    init() {
        // Configure FounderWish - you can configure everything at once
        // or just the boardKey first and set user info later
        FounderWish.configure(
            boardKey: "your-board-key",
            email: "user@example.com",
            paymentStatus: .free
        )
        
        // Or configure just the key first:
        // FounderWish.configure(boardKey: "your-board-key")
        // Then later: FounderWish.set(email: "user@example.com", paymentStatus: .paid)
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

