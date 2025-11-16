# Troubleshooting Guide

## Import Statement Issue

### ❌ Wrong Import:
```swift
import FoundationWish  // This won't work!
import founder_wish    // This won't work!
```

### ✅ Correct Import:
```swift
import FounderWish  // Capital F, Capital W
```

**Important:** The package is now named `FounderWish`, so the import is simply `FounderWish`.

## Common Issues and Solutions

### Issue 1: "No such module 'FounderWish'"

**Possible causes:**
1. Package not properly added to the project
2. Build cache issues
3. Package structure issues

**Solutions:**

1. **Verify package is added correctly:**
   - In Xcode, go to your project settings
   - Select your app target
   - Go to "General" tab
   - Under "Frameworks, Libraries, and Embedded Content"
   - Make sure `FounderWish` is listed
   - If not, add it via File → Add Packages...

2. **Clean build folder:**
   ```bash
   # In Xcode: Product → Clean Build Folder (Shift+Cmd+K)
   # Or from terminal:
   cd /path/to/your/app
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   ```

3. **Re-add the package:**
   - Remove the package from your project
   - File → Add Packages...
   - Click "Add Local..."
   - Navigate to `/Users/balu/Documents/Development/FounderWish`
   - Make sure "Add to Project" is selected
   - Click "Add Package"

4. **Verify package builds:**
   ```bash
   cd /Users/balu/Documents/Development/FounderWish
   swift build
   ```
   If this fails, there's an issue with the package itself.

### Issue 2: "Cannot find 'FounderWish' in scope"

**Solution:**
Make sure you've imported the module:
```swift
import FounderWish  // Capital F, Capital W
```

Then use:
```swift
FounderWish.configure(...)  // Capital F, capital W
FounderWish.FeedbackFormView()  // Views are nested
```

### Issue 3: Package shows but code doesn't autocomplete

**Solutions:**
1. Close and reopen Xcode
2. Clean build folder (Shift+Cmd+K)
3. Restart Xcode
4. Make sure you're building for the correct platform (iOS 15.0+)

### Issue 4: "Module 'founder_wish' was created for incompatible target"

**Solution:**
Make sure your app's deployment target matches:
- iOS 15.0 or higher
- Or macOS 12.0 or higher

Check in your app's project settings → General → Deployment Info

## Step-by-Step: Adding Local Package Correctly

1. **Open your iOS app project in Xcode**

2. **Add the package:**
   - File → Add Packages...
   - Click "Add Local..." button (bottom left)
   - Navigate to: `/Users/balu/Documents/Development/FounderWish`
   - Click "Add Package"

3. **Verify it's added:**
   - In Project Navigator, you should see "Package Dependencies" section
   - `FounderWish` should be listed there

4. **Add to target:**
   - Select your app target
   - Go to "General" tab
   - Scroll to "Frameworks, Libraries, and Embedded Content"
   - Click "+" button
   - Select `FounderWish`
   - Make sure it's set to "Do Not Embed"

5. **Use in your code:**
   ```swift
   import FounderWish  // Correct import
   
   // Then use:
   FounderWish.configure(secret: "your-secret")
   ```

## Quick Test

Create a simple test file to verify the import works:

```swift
import SwiftUI
import FounderWish  // This should work

struct TestView: View {
    var body: some View {
        Text("Testing")
            .onAppear {
                FounderWish.configure(secret: "test")
            }
    }
}
```

If this compiles, the package is working correctly!

## Still Having Issues?

1. **Check Xcode version:** Make sure you're using Xcode 14+ (for Swift 6.2 support)
2. **Check Swift version:** The package requires Swift 6.2
3. **Verify package structure:** Make sure all files are in `Sources/FounderWish/`
4. **Try building the package standalone:**
   ```bash
   cd /Users/balu/Documents/Development/FounderWish
   swift build
   ```

