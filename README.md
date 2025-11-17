# FounderWish

A Swift Package Manager library for collecting and managing user feedback in iOS apps. Easily integrate feedback forms, public feedback boards, and upvoting functionality into your SwiftUI applications.

## Features

- 📝 **Feedback Forms** - Beautiful SwiftUI forms for collecting feature requests and bug reports
- 💬 **Public Feedback Board** - Display and manage public feedback items with modern card layouts
- 👍 **Upvoting System** - Let users vote on feedback items
- 🎨 **Modern UI** - Clean, modern SwiftUI components that match iOS design guidelines
- 🔒 **Privacy Focused** - User data handling with customizable metadata
- 📱 **Cross-Platform** - Supports iOS 15.0+ and macOS 12.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/founder-wish.git", from: "1.0.0")
]
```

Or add it via Xcode:
1. File → Add Packages...
2. Enter the repository URL
3. Select the version

## Quick Start

### 1. Configure FounderWish

```swift
import FounderWish

// In your AppDelegate or App struct
FounderWish.configure(
    secret: "your-secret-key",
    email: "user@example.com",
    subscription: .paid,
    billingCycle: .monthly,
    amount: "$9.99"
)
```

### 2. Show Feedback Form

```swift
import SwiftUI
import FounderWish

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

### 3. Show Public Feedbacks

```swift
import SwiftUI
import FounderWish

struct FeedbacksListView: View {
    var body: some View {
        NavigationView {
            FounderWish.FeedbacksView()
        }
    }
}
```

### 4. Send Feedback Programmatically

```swift
Task {
    do {
        try await FounderWish.sendFeedback(
            title: "Feature Request",
            description: "Add dark mode support",
            category: "feature"
        )
    } catch {
        print("Error: \(error)")
    }
}
```

## Testing

### Option 1: Unit Tests (Local)

Run unit tests locally:

```bash
swift test
```

### Option 2: Create Example iOS App

To test the UI components, create a separate iOS app project:

1. **Create a new iOS App project in Xcode**
2. **Add the package as a dependency:**
   - File → Add Packages...
   - Click "Add Local..." 
   - Select the `FounderWish` package directory
   - Or use the file path: `/Users/balu/Documents/Development/FounderWish`

3. **Example App Code:**

```swift
import SwiftUI
import FounderWish

@main
struct ExampleApp: App {
    init() {
        // Configure FounderWish
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
    @State private var showFeedbacks = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button("Send Feedback") {
                    showFeedbackForm = true
                }
                .buttonStyle(.borderedProminent)
                
                Button("View Feedbacks") {
                    showFeedbacks = true
                }
                .buttonStyle(.bordered)
            }
            .navigationTitle("FounderWish Demo")
            .sheet(isPresented: $showFeedbackForm) {
                FounderWish.FeedbackFormView()
            }
            .sheet(isPresented: $showFeedbacks) {
                NavigationView {
                    FounderWish.FeedbacksView()
                }
            }
        }
    }
}
```

## API Reference

### Configuration

- `FounderWish.configure(secret:email:subscription:billingCycle:amount:overrideBaseURL:)` - Configure the SDK
- `FounderWish.updateUser(email:subscription:billingCycle:amount:)` - Update user information
- `FounderWish.setEmail(_:)` - Update email only
- `FounderWish.setSubscription(_:billingCycle:amount:)` - Update subscription only

### Feedback

- `FounderWish.sendFeedback(title:description:source:category:)` - Send feedback programmatically
- `FounderWish.fetchPublicItems(limit:)` - Fetch public feedback items
- `FounderWish.upvote(feedbackId:)` - Upvote a feedback item

### Views

- `FounderWish.FeedbackFormView()` - SwiftUI view for submitting feedback
- `FounderWish.FeedbacksView()` - SwiftUI view for displaying public feedbacks

## Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 6.2+

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

