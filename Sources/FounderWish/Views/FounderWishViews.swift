//
//  FounderWishViews.swift
//  founder-wish
//
//  Created by Balu on 11/16/25.
//

import SwiftUI

@available(iOS 15.0, *)
extension FounderWish {
    
    // MARK: - Feedback Form View
    
    /// A SwiftUI view for submitting feedback (feature requests or bug reports) to your app's feedback board.
    ///
    /// This view provides a form where users can:
    /// - Submit feature requests or bug reports
    /// - Add a title and optional description
    /// - Choose between "Feature Request" or "Bug Report" categories
    /// - Optionally provide email address (if enabled via `askForEmail` parameter)
    ///
    /// **Parameters:**
    /// - `askForEmail`: If `true`, shows an email text field in the form
    /// - `emailRequired`: If `true` (and `askForEmail` is `true`), email becomes mandatory
    ///
    /// **Usage:**
    /// ```swift
    /// import SwiftUI
    /// import FounderWish
    ///
    /// struct ContentView: View {
    ///     @State private var showFeedback = false
    ///
    ///     var body: some View {
    ///         Button("Send Feedback") {
    ///             showFeedback = true
    ///         }
    ///         .sheet(isPresented: $showFeedback) {
    ///             FounderWish.FeedbackFormView(
    ///                 askForEmail: true,
    ///                 emailRequired: false  // Set to true to make email mandatory
    ///             )
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// Make sure to call `FounderWish.configure(boardKey:)` before using this view.
    public struct FeedbackFormView: View {
        @Environment(\.dismiss) private var dismiss

        @State private var title = ""
        @State private var desc = ""
        @State private var email = ""
        @State private var busy = false
        @State private var errorText: String?
        @State private var success = false
        @State private var isBug = false   // false = feature, true = bug
        
        private let askForEmail: Bool
        private let emailRequired: Bool

        public init(askForEmail: Bool = false, emailRequired: Bool = false) {
            self.askForEmail = askForEmail
            self.emailRequired = emailRequired
        }

        public var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Feedback type")) {
                        Picker("What's this about?", selection: $isBug) {
                            Text("🚀 Feature Request").tag(false)
                            Text("🐞 Bug Report").tag(true)
                        }
                    }

                    Section(header: Text(isBug ? "Issue title" : "Title")) {
                        TextField(isBug ? "e.g. Crash when saving" : "e.g. Sort tasks by priority", text: $title)
                            #if os(iOS)
                            .textInputAutocapitalization(.sentences)
                            #endif
                    }

                    Section(header: Text(isBug ? "Describe the issue" : "Details")) {
                        TextEditor(text: $desc)
                            .frame(minHeight: 120)
                    }
                    
                    if askForEmail {
                        Section(header: Text("Email")) {
                            TextField("your@email.com", text: $email)
                                #if os(iOS)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .autocorrectionDisabled()
                                #endif
                        }
                    }

                    if let errorText {
                        Section { 
                            Text(errorText)
                                .foregroundStyle(.red)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }

                    if success {
                        Section {
                            HStack {
                                Spacer()
                                VStack(spacing: 12) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 50))
                                        .foregroundStyle(.green)
                                    
                                    Text("Thank you!")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("Your feedback was sent.")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 20)
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .opacity),
                                removal: .opacity
                            ))
                        }
                    }
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: success)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: errorText)
                .task {
                    await loadSavedEmail()
                }
                .navigationTitle(isBug ? "Bug Report" : "Feature Request")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", systemImage: "xmark") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        if busy {
                            ProgressView()
                        } else {
                            Button("Send") { Task { await send() } }
                                .disabled(!canSend)
                        }
                    }
                }
            }
        }

        private func loadSavedEmail() async {
            guard askForEmail else { return }
            let userProfile = await FounderWishCore.shared.getUserProfile()
            if let savedEmail = userProfile?.email, !savedEmail.isEmpty {
                await MainActor.run {
                    email = savedEmail
                }
            }
        }
        
        private var canSend: Bool {
            let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedTitle.isEmpty {
                return false
            }
            
            if askForEmail && emailRequired {
                let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                return !trimmedEmail.isEmpty && isValidEmail(trimmedEmail)
            }
            
            return true
        }
        
        private func isValidEmail(_ email: String) -> Bool {
            let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
            return emailPredicate.evaluate(with: email)
        }
        
        private func send() async {
            errorText = nil
            success = false
            busy = true
            
            // Validate email if required
            if askForEmail && emailRequired {
                let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedEmail.isEmpty {
                    errorText = "Email is required"
                    busy = false
                    return
                }
                if !isValidEmail(trimmedEmail) {
                    errorText = "Please enter a valid email address"
                    busy = false
                    return
                }
            }
            
            do {
                let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedDesc = desc.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedEmail = askForEmail ? email.trimmingCharacters(in: .whitespacesAndNewlines) : nil
                let category = isBug ? "bug" : "feature"

                try await FounderWish.sendFeedback(
                    title: trimmedTitle,
                    description: trimmedDesc.isEmpty ? nil : trimmedDesc,
                    category: category,
                    email: trimmedEmail?.isEmpty == false ? trimmedEmail : nil
                )

                success = true
                await MainActor.run {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { dismiss() }
                }
            } catch {
                errorText = error.localizedDescription
            }
            busy = false
        }
    }
    
    // MARK: - Feedbacks View
    
    /// A SwiftUI view that displays a list of public feedback items from your app's feedback board.
    ///
    /// This view shows:
    /// - All public feedback items (feature requests and bug reports)
    /// - Vote counts for each item
    /// - Ability to upvote feedback items
    /// - Pull-to-refresh functionality
    ///
    /// **Usage:**
    /// ```swift
    /// import SwiftUI
    /// import FounderWish
    ///
    /// struct FeedbacksListView: View {
    ///     var body: some View {
    ///         NavigationView {
    ///             FounderWish.FeedbacksView()
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// Make sure to call `FounderWish.configure(boardKey:)` before using this view.
    public struct FeedbacksView: View {
        @State private var items: [PublicItem] = []
        @State private var err: String?

        // Track which items are currently sending an upvote
        @State private var votingIds: Set<String> = []

        // Persisted "already voted" guard (per-device)
        @State private var votedIds: Set<String> = FeedbacksView.loadVotedIds()
        
        private let mockItems: [PublicItem]?

        public init() {
            self.mockItems = nil
        }
        
        // Internal initializer for previews
        internal init(mockItems: [PublicItem]) {
            self.mockItems = mockItems
        }

        public var body: some View {
            ScrollView {
                VStack(spacing: 12) {
                    if let err {
                        Text(err)
                            .foregroundStyle(.red)
                            .padding()
                    }
                    
                    ForEach(items, id: \.id) { item in
                        FeedbackRowView(
                            item: item,
                            isVoting: votingIds.contains(item.id),
                            alreadyVoted: votedIds.contains(item.id),
                            onVote: { id in
                                Task { await upvote(id) }
                            }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .task {
                if let mockItems = mockItems {
                    items = mockItems
                } else {
                    await load()
                }
            }
            .refreshable {
                if mockItems == nil {
                    await load()
                }
            }
            .navigationTitle("Feedbacks")
        }

        // MARK: - Data

        @MainActor
        private func load() async {
            err = nil
            do {
                items = try await FounderWish.fetchPublicItems()
            } catch {
                err = error.localizedDescription
            }
        }

        // MARK: - Upvote (server-synced)

        @MainActor
        private func upvote(_ id: String) async {
            guard !votedIds.contains(id), !votingIds.contains(id) else { return }
            err = nil
            
            // Update voting state
            votingIds.insert(id)

            // Optimistic: bump local count immediately by replacing the item
            if let idx = items.firstIndex(where: { $0.id == id }) {
                var updatedItem = items[idx]
                updatedItem.votes = (updatedItem.votes ?? 0) + 1
                items[idx] = updatedItem
            }

            do {
                // ✅ Fetch updated count from server
                let newCount = try await FounderWish.upvote(feedbackId: id)
                
                // Update voted state
                votedIds.insert(id)
                Self.saveVotedIds(votedIds)

                // ✅ Update item with actual server vote total by replacing it
                if let idx = items.firstIndex(where: { $0.id == id }) {
                    var updatedItem = items[idx]
                    updatedItem.votes = newCount
                    items[idx] = updatedItem
                }
            } catch {
                // Rollback on failure by replacing the item
                if let idx = items.firstIndex(where: { $0.id == id }) {
                    var updatedItem = items[idx]
                    updatedItem.votes = max(0, (updatedItem.votes ?? 1) - 1)
                    items[idx] = updatedItem
                }
                err = error.localizedDescription
            }

            // Remove from voting state
            votingIds.remove(id)
        }
        
        // MARK: - Local persistence for "already voted"

        private static let votedKey = "iw_voted_ids"

        private static func loadVotedIds() -> Set<String> {
            let arr = UserDefaults.standard.array(forKey: votedKey) as? [String] ?? []
            return Set(arr)
        }

        private static func saveVotedIds(_ set: Set<String>) {
            UserDefaults.standard.set(Array(set), forKey: votedKey)
        }
    }
    
    // MARK: - Feedback Row View (extracted for better performance)
    
    private struct FeedbackRowView: View {
        let item: PublicItem
        let isVoting: Bool
        let alreadyVoted: Bool
        let onVote: (String) -> Void
        
        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    if let d = item.description, !d.isEmpty {
                        Text(d)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                    }
                }
                
                Spacer()
                
                if alreadyVoted {
                    VStack(spacing: 4) {
                        Text("Voted")
                            .font(.caption)
                            .padding(8)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                            .background(.thinMaterial, in: .capsule)
                        
                        Image(systemName: "arrow.up")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Text("\(item.votes ?? 0)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(width: 60)
                } else {
                    Button {
                        onVote(item.id)
                    } label: {
                        VStack(spacing: 4) {
                            if isVoting {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "arrow.up")
                                    .font(.headline)
                            }
                            
                            Text("\(item.votes ?? 0)")
                                .font(.subheadline)
                        }
                        .frame(width: 60)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                    .disabled(isVoting)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.background)
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
        }
    }
}

#if DEBUG
@available(iOS 15.0, *)
struct FeedbackFormView_Previews: PreviewProvider {
    static var previews: some View {
        FounderWish.FeedbackFormView(askForEmail: true, emailRequired: false)
            
    }
}

@available(iOS 15.0, *)
struct FeedbacksView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FounderWish.FeedbacksView(mockItems: mockFeedbackItems)
        }
    }
    
    static var mockFeedbackItems: [PublicItem] {
        [
            PublicItem(
                id: "1",
                title: "Add dark mode support",
                description: "It would be great to have a dark mode option for better visibility at night.",
                status: "open",
                source: "ios",
                created_at: "2024-01-15T10:30:00Z",
                votes: 42
            ),
            PublicItem(
                id: "2",
                title: "Improve search functionality",
                description: "The search feature could be more intuitive and faster.",
                status: "in_progress",
                source: "ios",
                created_at: "2024-01-14T14:20:00Z",
                votes: 28
            ),
            PublicItem(
                id: "3",
                title: "Add export to PDF",
                description: nil,
                status: "open",
                source: "ios",
                created_at: "2024-01-13T09:15:00Z",
                votes: 15
            ),
            PublicItem(
                id: "4",
                title: "Fix crash when saving large files",
                description: "The app crashes when trying to save files larger than 100MB. This happens consistently on iPhone 12 Pro.",
                status: "open",
                source: "ios",
                created_at: "2024-01-12T16:45:00Z",
                votes: 67
            ),
            PublicItem(
                id: "5",
                title: "Add keyboard shortcuts",
                description: "Would love to see keyboard shortcuts for common actions to speed up workflow.",
                status: "planned",
                source: "ios",
                created_at: "2024-01-11T11:00:00Z",
                votes: 33
            ),
            PublicItem(
                id: "6",
                title: "Sync across devices",
                description: "It would be amazing if data could sync between iPhone and iPad automatically.",
                status: "open",
                source: "ios",
                created_at: "2024-01-10T08:30:00Z",
                votes: 89
            )
        ]
    }
}
#endif





