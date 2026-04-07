//
// UserPreferencesStorage.swift
// AnimeRecommendationTinder-Mobile project
//
// Manages saving and loading the user's questionnaire preferences
// using UserDefaults and @AppStorage-compatible keys.
//
// Stores three values:
//   - An array of preferred Jikan genre IDs (saved as JSON Data)
//   - An experience level string ("new", "some", "experienced")
//   - An episode preference string ("short", "medium", "long", "any")
//
// Also stores a boolean flag tracking whether the user has
// completed the questionnaire — used to decide whether to show
// the onboarding flow or go straight to the main app.
//

import Foundation

class UserPreferencesStorage {

    // MARK: - Singleton
    static let shared = UserPreferencesStorage()
    private init() {}

    // MARK: - Storage Keys
    // Defined as constants to prevent typos causing silent failures

    private let hasCompletedQuestionnaireKey = "has_completed_questionnaire"
    private let preferredGenreIDsKey         = "preferred_genre_ids"
    private let experienceLevelKey           = "experience_level"
    private let episodePreferenceKey         = "episode_preference"

    // MARK: - Public Functions

    /// Returns true if the user has already completed the questionnaire.
    /// Used by ContentView to decide whether to show onboarding or main tabs.
    var hasCompletedQuestionnaire: Bool {
        UserDefaults.standard.bool(forKey: hasCompletedQuestionnaireKey)
    }

    /// Saves all questionnaire answers and marks onboarding as complete.
    func savePreferences(genreIDs: [Int], experienceLevel: String, episodePreference: String) {
        // Encode the genre ID array as JSON Data so UserDefaults can store it
        if let encoded = try? JSONEncoder().encode(genreIDs) {
            UserDefaults.standard.set(encoded, forKey: preferredGenreIDsKey)
        }

        UserDefaults.standard.set(experienceLevel, forKey: experienceLevelKey)
        UserDefaults.standard.set(episodePreference, forKey: episodePreferenceKey)

        // Mark questionnaire as done so we never show it again automatically
        UserDefaults.standard.set(true, forKey: hasCompletedQuestionnaireKey)
    }

    /// Returns the genre IDs the user selected during the questionnaire.
    /// Returns an empty array if the questionnaire has not been completed.
    func loadPreferredGenreIDs() -> [Int] {
        guard let data = UserDefaults.standard.data(forKey: preferredGenreIDsKey),
              let decoded = try? JSONDecoder().decode([Int].self, from: data) else {
            return []
        }
        return decoded
    }

    /// Returns the experience level string saved during the questionnaire.
    func loadExperienceLevel() -> String {
        return UserDefaults.standard.string(forKey: experienceLevelKey) ?? "new"
    }

    /// Returns the episode preference string saved during the questionnaire.
    func loadEpisodePreference() -> String {
        return UserDefaults.standard.string(forKey: episodePreferenceKey) ?? "any"
    }

    /// Clears all saved preferences — used by the Settings screen reset option.
    func resetPreferences() {
        UserDefaults.standard.removeObject(forKey: hasCompletedQuestionnaireKey)
        UserDefaults.standard.removeObject(forKey: preferredGenreIDsKey)
        UserDefaults.standard.removeObject(forKey: experienceLevelKey)
        UserDefaults.standard.removeObject(forKey: episodePreferenceKey)
    }
}
