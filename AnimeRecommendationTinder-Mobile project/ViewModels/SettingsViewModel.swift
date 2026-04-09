//
// SettingsViewModel.swift
// AnimeRecommendationTinder-Mobile project
//
// The ViewModel for the Settings screen.
// Responsible for:
//   - Exposing the safe content toggle state
//   - Handling the reset preferences action
//   - Providing app information for the about section
//
// Settings are lightweight — most state is managed directly
// via @AppStorage in the View, so this ViewModel is intentionally
// simple. Its main job is handling the reset action which
// requires coordination between UserPreferencesStorage and
// the app's navigation state.
//

import Foundation
import Combine
import SwiftUI


@MainActor
class SettingsViewModel: ObservableObject {
    
        // Pointer - Published Properties

        /// Controls whether to show the reset confirmation alert.
        /// Set to true when the user taps Reset Preferences.
    

    @Published var showingResetAlert: Bool = false
    
    
    
    
    /// This will be set to true after a successfuly reset -
    /// This tells ContentView to show the questionnarie again on the next launch
    @Published var didResetPreferences: Bool = false
    
    
    
    // Pointer - public functions
    
    
    // This will show confirmation before users reset their preferences
    // asking for confirmation is crucial before doing anything that could be seemed as definite
    
    func requestReset(){
        showingResetAlert = true
    }
    
    // clears all the answers/results from the questionnarie within User Defaults
    // This will be called when a user selects that they want to confirm the reste alert
    // so then now on the next app launch the questionnaire will pop up
    func confirmReset(){
        UserPreferencesStorage.shared.resetPreferences()
        didResetPreferences = true
    }
    
    
}
