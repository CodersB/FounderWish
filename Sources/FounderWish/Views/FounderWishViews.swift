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
    
    public struct FeedbackFormView: View {
        @Environment(\.dismiss) private var dismiss

        @State private var title = ""
        @State private var desc = ""
        @State private var busy = false
        @State private var errorText: String?
        @State private var success = false
        @State private var isBug = false   // false = feature, true = bug

        public init() {}

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

                    if let errorText {
                        Section { Text(errorText).foregroundStyle(.red) }
                    }

                    if success {
                        Section {
                            Label("Thank you! Your feedback was sent.", systemImage: "checkmark.circle.fill")
                                .font(.title3)
                        }
                    }
                }
                .navigationTitle(isBug ? "Bug Report" : "Feature Request")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        if busy {
                            ProgressView()
                        } else {
                            Button("Send") { Task { await send() } }
                                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }
        }

        private func send() async {
            errorText = nil
            success = false
            busy = true
            do {
                let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
                let trimmedDesc = desc.trimmingCharacters(in: .whitespacesAndNewlines)
                let category = isBug ? "bug" : "feature"

                try await FounderWish.sendFeedback(
                    title: trimmedTitle,
                    description: trimmedDesc.isEmpty ? nil : trimmedDesc,
                    category: category
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
                    .frame(width: 50)
                }
                .buttonStyle(.borderedProminent)
                .tint(alreadyVoted ? .gray : .accentColor)
                .disabled(isVoting || alreadyVoted)
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
        FounderWish.FeedbackFormView()
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

