//
// SavedViewModel.swift
// AnimeRecommendationTinder-Mobile project
//
// The ViewModel for the Saved/Watchlist screen.
// Responsible for:
//   - Loading the user's saved anime from SavedAnimeStorage
//   - Handling removal of anime from the saved list
//   - Keeping the list up to date when the user navigates to this tab
//
// This is a simpler ViewModel than others in the project
// because SavedAnimeStorage handles all the persistence logic.
// This ViewModel just reads from it and exposes the results to the View.
//

import Foundation
import Combine

@MainActor
class SavedViewModel: ObservableObject {

    // Pointer - Published Properties

    /// The list of anime the user has saved to their watchlist.
    /// Loaded fresh every time the Saved tab is opened.
    @Published var savedAnime: [AnimeItem] = []

    /// True while the saved list is being loaded.
    /// Used to show a brief loading state on first appear.
    @Published var isLoading: Bool = false

    // Pointer - Public Functions

    /// Loads all saved anime from UserDefaults via SavedAnimeStorage.
    /// Called every time the Saved tab appears so the list stays
    /// in sync with any changes made on the Detail or Discover screens.
    func loadSaved() {
        isLoading = true
        savedAnime = SavedAnimeStorage.shared.loadAll()
        isLoading = false
    }

    /// Removes an anime from the saved list by its MAL ID.
    /// Called when the user swipes to delete a row or taps remove.
    /// Updates both UserDefaults and the local published array
    /// so the UI reflects the change immediately.
    func remove(animeID: Int) {
        SavedAnimeStorage.shared.remove(animeID: animeID)
        // Also remove from the local array so the list
        // updates instantly without needing to reload from storage
        savedAnime.removeAll { $0.id == animeID }
    }
}
