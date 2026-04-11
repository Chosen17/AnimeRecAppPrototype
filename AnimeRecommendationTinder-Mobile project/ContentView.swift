//
// ContentView.swift
// AnimeRecommendationTinder-Mobile project
//
// The root view of the entire app.
// Manages three states:
//   1. Not logged in — shows LoginView
//   2. Logged in but questionnaire not done — shows QuestionnaireView
//   3. Logged in and questionnaire done — shows main TabView
//
// This ensures each user's preferences and saved anime
// are tied to their account and never overlap with other users.
//

import SwiftUI

struct ContentView: View {

    // Pointer - State
    @State private var isLoggedIn: Bool = APIService.shared.isLoggedIn
    @State private var hasCompletedQuestionnaire: Bool =
        UserPreferencesStorage.shared.hasCompletedQuestionnaire

    // Pointer - Body
    var body: some View {
        if !isLoggedIn {
            // State 1 — show login/signup
            LoginView {
                isLoggedIn = true
            }
        } else if !hasCompletedQuestionnaire {
            // State 2 — logged in but needs questionnaire
            QuestionnaireView {
                hasCompletedQuestionnaire = true
            }
        } else {
            // State 3 — fully set up, show main app
            mainTabView
        }
    }

    // Pointer - Main Tab View
    private var mainTabView: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "rectangle.stack.fill")
                }

            SavedView()
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .tint(.purple)
    }
}

#Preview {
    ContentView()
}
