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

        public init() {}

        public var body: some View {
            List {
                if let err {
                    Text(err).foregroundStyle(.red)
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
            .listStyle(.plain)
            .task { await load() }
            .refreshable { await load() }
            .navigationTitle("Ideas")
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
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title).font(.headline)
                    if let d = item.description, !d.isEmpty {
                        Text(d)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Text("votes: \(item.votes ?? 0) · status: \(item.status)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()

                Button {
                    onVote(item.id)
                } label: {
                    VStack(spacing: 3) {
                        if isVoting {
                            ProgressView()
                                .controlSize(.small)
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.up")
                                .font(.system(size: 17, weight: .bold))
                        }
                        Text("\(item.votes ?? 0)")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .frame(minWidth: 56, minHeight: 56)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.borderedProminent)
                .tint(alreadyVoted ? .gray : .blue)
                .disabled(isVoting || alreadyVoted)
                .controlSize(.large)
            }
            .padding(.vertical, 4)
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
        FounderWish.FeedbacksView()
    }
}
#endif

