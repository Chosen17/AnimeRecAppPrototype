//
// QuestionnaireViewModel.swift
// AnimeRecommendationTinder-Mobile project
//
// The ViewModel for the Questionnaire onboarding screen.
// Responsible for:
//   - Holding the user's answers as they progress through the questions
//   - Saving completed preferences to UserDefaults via UserPreferencesStorage
//   - Tracking which step of the questionnaire the user is on
//
// The questionnaire collects three things:
//   1. Favourite genres (multi-select from a list)
//   2. Viewing experience level (new / some / experienced)
//   3. Preferred episode length (short / medium / long / any)
//
// These answers are saved locally and used by DiscoverViewModel
// to filter Jikan API results for the swipe screen.
//

import Foundation
import Combine

@MainActor
class QuestionnaireViewModel: ObservableObject {

    // MARK: - Step Tracking

    /// The index of the question currently shown (0-based).
    /// QuestionnaireView watches this to show the correct step.
    @Published var currentStep: Int = 0

    /// Total number of steps in the questionnaire.
    /// Used to draw the progress indicator and know when we are done.
    let totalSteps: Int = 3

    /// True when the user has completed all steps and saved their preferences.
    /// QuestionnaireView uses this to dismiss the questionnaire.
    @Published var isComplete: Bool = false

    // MARK: - User Answers

    /// The set of genre IDs the user has selected.
    /// A Set prevents duplicates — tapping the same genre twice removes it.
    /// Jikan genre IDs: 1=Action, 2=Adventure, 4=Comedy, 8=Drama,
    /// 10=Fantasy, 14=Horror, 22=Romance, 37=Supernatural, 7=Mystery
    @Published var selectedGenreIDs: Set<Int> = []

    /// The user's self-reported anime experience level.
    /// Stored as a String so it can be saved directly to UserDefaults.
    @Published var experienceLevel: String = "new"

    /// The user's preferred episode count range.
    @Published var episodePreference: String = "any"

    // MARK: - Available Options

    /// The genre options shown in step 1.
    /// Each tuple contains the Jikan genre ID and its display name.
    let availableGenres: [(id: Int, name: String)] = [
        (1,  "Action"),
        (2,  "Adventure"),
        (4,  "Comedy"),
        (8,  "Drama"),
        (10, "Fantasy"),
        (14, "Horror"),
        (22, "Romance"),
        (37, "Supernatural"),
        (7,  "Mystery"),
        (36, "Slice of Life")
    ]

    /// Experience level options shown in step 2.
    let experienceOptions: [(value: String, label: String, description: String)] = [
        ("new",        "Brand new",    "I have never watched anime before"),
        ("some",       "Some",         "I have watched a few series"),
        ("experienced","Experienced",  "I watch anime regularly")
    ]

    /// Episode preference options shown in step 3.
    let episodeOptions: [(value: String, label: String, description: String)] = [
        ("short",  "Short",  "Under 15 episodes — quick to finish"),
        ("medium", "Medium", "15 to 50 episodes — a good commitment"),
        ("long",   "Long",   "50+ episodes — I want an epic journey"),
        ("any",    "Any",    "I have no preference on length")
    ]

    // MARK: - Navigation

    /// Moves to the next step, or completes the questionnaire
    /// if the user is already on the last step.
    func nextStep() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
        } else {
            saveAndComplete()
        }
    }

    /// Moves back to the previous step.
    /// Called by the Back button on steps 1 and 2.
    func previousStep() {
        guard currentStep > 0 else { return }
        currentStep -= 1
    }

    /// Toggles a genre in the selected set.
    /// If already selected, removes it. If not, adds it.
    func toggleGenre(id: Int) {
        if selectedGenreIDs.contains(id) {
            selectedGenreIDs.remove(id)
        } else {
            selectedGenreIDs.insert(id)
        }
    }

    // MARK: - Save

    /// Saves the completed questionnaire answers to UserDefaults
    /// and marks the questionnaire as finished.
    private func saveAndComplete() {
        // Convert the Set to a sorted Array for consistent storage
        let genreArray = Array(selectedGenreIDs).sorted()

        UserPreferencesStorage.shared.savePreferences(
            genreIDs: genreArray,
            experienceLevel: experienceLevel,
            episodePreference: episodePreference
        )

        // Mark as complete — QuestionnaireView will dismiss
        isComplete = true
    }
}
