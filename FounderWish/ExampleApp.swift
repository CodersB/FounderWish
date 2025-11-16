//
//  ExampleApp.swift
//  Example iOS App for Testing FounderWish
//
//  This is a reference implementation showing how to use FounderWish
//  in a real iOS app. Copy this code into a new Xcode iOS project.
//

import SwiftUI
import FounderWish

@main
struct ExampleApp: App {
    init() {
        // Configure FounderWish when app launches
        FounderWish.configure(
            secret: "your-secret-key-here",
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
    @State private var showFeedbackForm = false
    @State private var showFeedbacks = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("FounderWish Demo")
                    .font(.largeTitle)
                    .padding()
                
                VStack(spacing: 20) {
                    Button {
                        showFeedbackForm = true
                    } label: {
                        Label("Send Feedback", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button {
                        showFeedbacks = true
                    } label: {
                        Label("View Feedbacks", systemImage: "list.bullet")
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("FounderWish")
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

#Preview {
    ContentView()
}

