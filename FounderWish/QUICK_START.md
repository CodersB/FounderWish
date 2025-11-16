# Quick Start Guide

## Correct Import Statement

```swift
import FounderWish  // ✅ Correct - Capital F, Capital W
```

**NOT:**
```swift
import FoundationWish  // ❌ Wrong!
import founder_wish    // ❌ Wrong!
import founder-wish    // ❌ Wrong!
```

## Complete Example

```swift
import SwiftUI
import FounderWish  // ← Correct import

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
            FounderWish.FeedbackFormView()  // ← Use FounderWish (capital F, capital W)
        }
    }
}
```

## Adding the Package in Xcode

1. **File → Add Packages...**
2. Click **"Add Local..."** button
3. Navigate to: `/Users/balu/Documents/Development/founder-wish`
4. Click **"Add Package"**
5. Make sure it's added to your app target

## Verification

If the import works, you should see:
- Autocomplete when typing `FounderWish.`
- No red errors under `import founder_wish`
- The package listed in Project Navigator under "Package Dependencies"

## Still Not Working?

1. **Clean Build Folder:** Shift+Cmd+K
2. **Restart Xcode**
3. **Verify package builds:** 
   ```bash
   cd /Users/balu/Documents/Development/founder-wish
   swift build
   ```
4. **Check your app's deployment target:** Must be iOS 15.0+ or macOS 12.0+

