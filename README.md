# FounderWish

A Swift Package Manager library for collecting and managing user feedback in iOS apps. Easily integrate feedback forms, public feedback boards, and upvoting functionality into your SwiftUI applications.

## Features

- 📝 **Feedback Forms** - Simple SwiftUI forms for collecting feature requests and bug reports
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
    .package(url: "https://github.com/CodersB/FounderWish.git", from: "1.0.5")
]
```

Or add it via Xcode:
1. File → Add Packages...
2. Enter the repository URL
3. Select the version

## Quick Start

### 1. Configure FounderWish

You can configure everything at once, or just the board key first and set user information later.

**Option 1: Configure everything at once**
```swift
import FounderWish

// In your AppDelegate or App struct
FounderWish.configure(
    boardKey: "your-board-key",
    email: "user@example.com",
    paymentStatus: .paid,
    billingCycle: .monthly,
    amount: "$9.99"
)
```

**Option 2: Configure just the board key first**
```swift
import FounderWish

// Configure with just the board key
FounderWish.configure(boardKey: "your-board-key")

// Later, when user info is available, update it:
FounderWish.set(email: "user@example.com", paymentStatus: .paid)
```

**Payment Status Options:**
- `.free` - Free users (default)
- `.trial` - Trial users
- `.paid` - Paid users (subscriptions or one-time purchases)
- `.premium` - Premium tier users

**Billing Cycle Options:**
- `.weekly` - Weekly subscriptions
- `.monthly` - Monthly subscriptions
- `.yearly` - Yearly subscriptions
- `.lifetime` - One-time purchases / lifetime access

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
   - Enter: `https://github.com/CodersB/FounderWish.git`
   - Select the version you want
   - Click "Add Package"

3. **Example App Code:**

```swift
import SwiftUI
import FounderWish

@main
struct ExampleApp: App {
    init() {
        // Configure FounderWish
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

- `FounderWish.configure(boardKey:email:paymentStatus:billingCycle:amount:overrideBaseURL:)` - Configure the SDK
  - Configure everything at once, or just the `boardKey` first
  - All parameters except `boardKey` are optional
- `FounderWish.set(email:paymentStatus:billingCycle:amount:)` - Update user information
  - Update any combination of user info
  - All parameters are optional - only provide what you want to update

**Usage Examples:**

```swift
// Configure with board key only
FounderWish.configure(boardKey: "your-board-key")

// Update user email
FounderWish.set(email: "user@example.com")

// Update payment status for subscription
FounderWish.set(paymentStatus: .paid, billingCycle: .monthly, amount: "$9.99")

// Update payment status for one-time purchase
FounderWish.set(paymentStatus: .paid, billingCycle: .lifetime, amount: "$49.99")

// Update everything at once
FounderWish.set(
    email: "user@example.com",
    paymentStatus: .paid,
    billingCycle: .yearly,
    amount: "$99.99"
)
```

### Views

- `FounderWish.FeedbackFormView()` - SwiftUI view for submitting feedback
- `FounderWish.FeedbacksView()` - SwiftUI view for displaying public feedbacks

**Note:** The feedback API functions (`sendFeedback`, `fetchPublicItems`, `upvote`) are internal and used by the views. Use the provided SwiftUI views for the best experience.

## Requirements

- iOS 15.0+ / macOS 12.0+
- Swift 6.2+

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

