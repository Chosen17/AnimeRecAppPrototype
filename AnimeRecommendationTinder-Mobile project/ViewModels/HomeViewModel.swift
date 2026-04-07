//
// HomeViewModel.swift
// AnimeRecommendationTinder-Mobile project
//
// The ViewModel for the Home screen.
// Sits between HomeView (the UI) and JikanService (the API).
//
// Responsibilities:
//   - Fetching top/trending anime from Jikan on screen load
//   - Handling search queries typed by the user
//   - Exposing loading and error states so the View can react
//
// Why @MainActor?
// Network calls happen on background threads. @MainActor ensures
// that when we update published properties (which drive the UI),
// those updates always happen on the main thread — preventing crashes.
//

import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {

    // MARK: - Published Properties
    // Any change to these properties automatically triggers
    // the HomeView to re-render with the new data.

    /// The list of anime currently shown on the home screen.
    /// Starts as top/trending anime, switches to search results
    /// when the user types in the search bar.
    @Published var animeList: [AnimeItem] = []

    /// True while any network request is in progress.
    /// HomeView shows a loading spinner when this is true.
    @Published var isLoading: Bool = false

    /// Holds an error message if a network call fails.
    /// HomeView shows an alert or inline message when this is not nil.
    @Published var errorMessage: String? = nil

    /// The text the user has typed into the search bar.
    /// HomeView binds directly to this with $searchText.
    @Published var searchText: String = ""

    // MARK: - Private Properties

    /// The service that handles all Jikan API communication.
    /// Private because only this ViewModel should call it.
    private let jikanService = JikanService()

    /// Tracks the most recent search task so we can cancel it
    /// if the user types again before the previous search finishes.
    /// This prevents older results overwriting newer ones.
    private var searchTask: Task<Void, Never>? = nil

    // MARK: - Public Functions

    /// Loads the top-ranked anime from Jikan.
    /// Called automatically when the Home screen first appears.
    func loadTopAnime() async {
        // Show the loading spinner and clear any previous error
        isLoading = true
        errorMessage = nil

        do {
            // fetchTopAnime() is async — this line pauses until
            // Jikan responds, without freezing the UI
            let results = try await jikanService.fetchTopAnime()
            animeList = results
        } catch {
            // If anything goes wrong, store the message for the View to display
            errorMessage = error.localizedDescription
        }

        // Always hide the spinner when done, whether it succeeded or failed
        isLoading = false
    }

    /// Performs a search against Jikan using the current searchText.
    /// If searchText is empty, reloads the top anime list instead.
    ///
    /// Debounced — we cancel any in-progress search before starting a new one.
    /// This prevents firing a new API request for every single character typed.
    func performSearch() {
        // Cancel any search that's already running
        searchTask?.cancel()

        // If the search bar is cleared, go back to showing top anime
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else {
            Task { await loadTopAnime() }
            return
        }

        // Start a new search task
        searchTask = Task {
            // Brief pause (0.4 seconds) so we don't fire a request
            // on every single keystroke — only when the user pauses typing
            try? await Task.sleep(nanoseconds: 400_000_000)

            // Check if this task was cancelled during the sleep
            guard !Task.isCancelled else { return }

            isLoading = true
            errorMessage = nil

            do {
                let results = try await jikanService.searchAnime(query: searchText)
                // Only update the list if this task wasn't cancelled
                // while the network request was in flight
                guard !Task.isCancelled else { return }
                animeList = results
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }
}
