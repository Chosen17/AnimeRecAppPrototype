//
// AnimeDetailViewModel.swift
// AnimeRecommendationTinder-Mobile project
//
// The ViewModel for the Anime Detail screen.
// Responsible for:
//   - Fetching full anime details from Jikan using the anime's MAL ID
//   - Managing the saved/watchlist state for this anime
//   - Exposing loading and error states to AnimeDetailView
//
// The detail endpoint returns more data than the list endpoint —
// including full synopsis, studios, and broadcast info.
//

import Foundation
import Combine

@MainActor
class AnimeDetailViewModel: ObservableObject {

    // MARK: - Published Properties

    /// The fully loaded anime detail object.
    /// Starts as nil — the View shows a loading spinner until this is set.
    @Published var anime: AnimeItem? = nil

    /// True while the detail network request is in progress.
    @Published var isLoading: Bool = false

    /// Holds an error message string if the detail fetch fails.
    @Published var errorMessage: String? = nil

    /// Whether this anime is currently saved to the user's watchlist.
    /// Reads from and writes to UserDefaults via StorageService.
    @Published var isSaved: Bool = false

    // MARK: - Private Properties

    /// The Jikan API service — same instance used throughout the app.
    private let jikanService = JikanService()

    /// The MAL ID of the anime to load.
    /// Set once when this ViewModel is initialised and never changes.
    private let animeID: Int

    // MARK: - Initialiser

    /// Creates a new detail ViewModel for a specific anime.
    /// - Parameter animeID: The MyAnimeList ID from the Jikan list response.
    init(animeID: Int) {
        self.animeID = animeID
    }

    // MARK: - Public Functions

    /// Fetches the full detail for this anime from Jikan.
    /// Called automatically when AnimeDetailView appears.
    func loadDetail() async {
        isLoading = true
        errorMessage = nil

        do {
            let result = try await jikanService.fetchAnimeDetail(id: animeID)
            anime = result
            // Check if this anime is already in the user's saved list
            isSaved = SavedAnimeStorage.shared.isSaved(animeID: animeID)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Toggles whether this anime is saved to the watchlist.
    /// If it was saved, it removes it. If it wasn't, it adds it.
    /// Called when the user taps the bookmark button.
    func toggleSaved() {
        guard let anime = anime else { return }

        if isSaved {
            SavedAnimeStorage.shared.remove(animeID: animeID)
        } else {
            SavedAnimeStorage.shared.save(anime: anime)
        }

        // Toggle the local state so the button icon updates immediately
        // without needing to re-read from storage
        isSaved.toggle()
    }
}
