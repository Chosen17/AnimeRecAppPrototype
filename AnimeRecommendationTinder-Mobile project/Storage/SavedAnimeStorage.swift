//
// SavedAnimeStorage.swift
// AnimeRecommendationTinder-Mobile project
//
// Manages the user's saved/watchlist anime using UserDefaults.
//
// Why UserDefaults?
// The saved list is a small amount of user-specific data that needs
// to persist between app launches. UserDefaults is the simplest
// built-in iOS storage for this use case — no database setup needed.
// We encode AnimeItem structs to JSON using JSONEncoder before storing,
// and decode them back using JSONDecoder when reading.
//
// This is a singleton (shared instance) so any part of the app
// can read or write the saved list without passing the object around.
//

import Foundation

class SavedAnimeStorage {

    // MARK: - Singleton

    /// The single shared instance used throughout the app.
    /// Access via SavedAnimeStorage.shared everywhere.
    static let shared = SavedAnimeStorage()

    // Private init prevents anyone creating a second instance
    private init() {}

    // MARK: - Private Properties

    /// The key used to store and retrieve the saved list in UserDefaults.
    /// Using a constant prevents typos causing silent storage failures.
    private let storageKey = "saved_anime_list"

    // MARK: - Public Functions

    /// Returns all anime currently in the user's saved list.
    /// Decodes from JSON stored in UserDefaults.
    /// Returns an empty array if nothing has been saved yet.
    func loadAll() -> [AnimeItem] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([AnimeItem].self, from: data) else {
            // Nothing saved yet — return empty array rather than crashing
            return []
        }
        return decoded
    }

    /// Saves a new anime to the watchlist.
    /// If it is already saved, this does nothing (no duplicates).
    /// - Parameter anime: The AnimeItem to save.
    func save(anime: AnimeItem) {
        var current = loadAll()

        // Guard against duplicates — check by MAL ID
        guard !current.contains(where: { $0.id == anime.id }) else { return }

        current.append(anime)
        persist(current)
        
        Task{
            try? await APIService.shared.saveAnime(anime: anime)
        }
    }

    /// Removes an anime from the watchlist by its MAL ID.
    /// If the anime is not in the list, this does nothing safely.
    /// - Parameter animeID: The MAL ID of the anime to remove.
    func remove(animeID: Int) {
        var current = loadAll()
        current.removeAll { $0.id == animeID }
        persist(current)
        
        // This syncs removal to the Rails backend
        Task{
            try? await APIService.shared.removeAnime(malID: animeID)
        }
    }

    /// Returns true if an anime with the given MAL ID is in the saved list.
    /// Used to set the initial saved state when the detail screen opens.
    /// - Parameter animeID: The MAL ID to check.
    func isSaved(animeID: Int) -> Bool {
        return loadAll().contains(where: { $0.id == animeID })
    }

    // MARK: - Private Helpers

    /// Encodes the anime array to JSON and writes it to UserDefaults.
    /// Called internally after every save or remove operation.
    private func persist(_ list: [AnimeItem]) {
        if let encoded = try? JSONEncoder().encode(list) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
}
