# Troubleshooting Guide

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
   - In Xcode: Product → Clean Build Folder (Shift+Cmd+K)
   - Or delete DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData/*`

3. **Re-add the package:**
   - Remove the package from your project
   - File → Add Packages...
   - Enter the GitHub URL: `https://github.com/CodersB/FounderWish.git`
   - Select the version you want
   - Click "Add Package"

4. **Verify package builds:**
   - Try building your project (Cmd+B)
   - If it fails, check that you're using the correct import: `import FounderWish`

### Issue 2: "Cannot find 'FounderWish' in scope"

**Solution:**
Make sure you've imported the module:
```swift
import FounderWish
```

Then use:
```swift
FounderWish.configure(boardKey: "your-board-key")
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

## Step-by-Step: Adding Package via GitHub

1. **Open your iOS app project in Xcode**

2. **Add the package:**
   - File → Add Packages...
   - Enter: `https://github.com/CodersB/FounderWish.git`
   - Select version: "Up to Next Major Version" or specific version
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
   import FounderWish
   
   // Then use:
   FounderWish.configure(boardKey: "your-board-key")
   ```

## Still Having Issues?

1. **Check Xcode version:** Make sure you're using Xcode 14+ (for Swift 6.2 support)
2. **Check Swift version:** The package requires Swift 6.2
3. **Reset Package Caches:** File → Packages → Reset Package Caches
4. **Update Package:** File → Packages → Update to Latest Package Versions

