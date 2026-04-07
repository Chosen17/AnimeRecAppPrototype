//
// ContentView.swift
// AnimeRecommendationTinder-Mobile project
//
// The root view of the entire app.
//
// On first launch: shows QuestionnaireView (onboarding).
// After questionnaire is complete: shows the main TabView.
//
// Uses UserPreferencesStorage to check whether the user
// has already completed the questionnaire, so returning
// users go straight to the main app without seeing it again.
//

import SwiftUI

struct ContentView: View {

    // MARK: - State

    /// Tracks whether the questionnaire has been completed.
    /// Starts by reading from UserDefaults — false on first launch,
    /// true for returning users who already set their preferences.
    @State private var hasCompletedQuestionnaire: Bool =
        UserPreferencesStorage.shared.hasCompletedQuestionnaire

    // MARK: - Body

    var body: some View {
        if hasCompletedQuestionnaire {
            // Returning user — show main app directly
            mainTabView
        } else {
            // New user — show onboarding questionnaire
            QuestionnaireView {
                // This closure is called when the user taps Finish
                // Switches the UI to the main TabView
                hasCompletedQuestionnaire = true
            }
        }
    }

    // MARK: - Main Tab View

    /// The four-tab main interface shown after onboarding is complete.
    private var mainTabView: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // placed holder has now been replace with actual functionality
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "rectangle.stack.fill")
                }

            Text("Saved coming soon")
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill")
                }

            Text("Settings coming soon")
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
