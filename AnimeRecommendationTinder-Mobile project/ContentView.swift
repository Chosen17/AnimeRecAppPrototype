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
// Uses a NotificationCenter observer so that when the user
// signs out from Settings, ContentView immediately switches
// back to the login screen without needing a full app restart.
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
            LoginView {
                // Re-read both states fresh from storage after login
                isLoggedIn = APIService.shared.isLoggedIn
                hasCompletedQuestionnaire = UserPreferencesStorage.shared.hasCompletedQuestionnaire
            }
        } else if !hasCompletedQuestionnaire {
            QuestionnaireView {
                hasCompletedQuestionnaire = true
            }
        } else {
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
            SettingsView(onSignOut: {
                // Clear both states so login screen shows immediately
                isLoggedIn = false
                hasCompletedQuestionnaire = false
            })
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
