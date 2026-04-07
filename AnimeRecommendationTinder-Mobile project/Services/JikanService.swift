//
// JikanService.swift
// AnimeRecommendationTinder-Mobile project
//
// Responsible for all communication with the Jikan REST API.
// Jikan is a free, unofficial MyAnimeList API — no API key required.
// Base URL: https://api.jikan.moe/v4
//
// This file sits in the Services layer of our MVVM architecture.
// ViewModels call these functions — Views never touch this file directly.
//
// Jikan has a rate limit of 3 requests per second on the free tier.
// We handle errors gracefully so the UI can show a message if a call fails.
//

import Foundation

// MARK: - Custom Error Type

/// Describes the ways a Jikan API call can go wrong.
/// Using a custom error type means our ViewModels can show
/// meaningful messages to the user rather than a raw system error.
enum JikanError: Error, LocalizedError {
    case invalidURL
    case networkFailure(Error)
    case decodingFailure(Error)
    case noResults

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The API URL was malformed. Please report this bug."
        case .networkFailure(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingFailure(let error):
            return "Failed to read the response from Jikan: \(error.localizedDescription)"
        case .noResults:
            return "No anime results were found for your search."
        }
    }
}

// MARK: - JikanService

/// The single entry point for all Jikan API calls in this app.
/// Marked as a class so it can be used as an @StateObject or @ObservedObject
/// in ViewModels if needed. All functions are async — they run in the
/// background so the UI never freezes while waiting for a response.
class JikanService {

    // The base URL all Jikan endpoints share.
    // Stored here so if Jikan ever changes their URL we only update one line.
    private let baseURL = "https://api.jikan.moe/v4"

    // MARK: - Fetch Top Anime

    /// Fetches the current top-ranked anime from Jikan.
    /// Used on the Home screen to populate the trending section.
    ///
    /// - Parameter page: Which page of results to load (default is 1).
    ///   Jikan returns 25 results per page.
    /// - Returns: An array of AnimeItem models ready for the UI to display.
    /// - Throws: A JikanError if the network call or decoding fails.
    func fetchTopAnime(page: Int = 1) async throws -> [AnimeItem] {
        // Build the URL string using our base URL and the /top/anime endpoint
        let urlString = "\(baseURL)/top/anime?page=\(page)"

        // Attempt to create a valid URL object — fail early if malformed
        guard let url = URL(string: urlString) else {
            throw JikanError.invalidURL
        }

        // Make the network request using Swift's built-in URLSession.
        // 'async throws' means this line pauses here until the response
        // arrives, without blocking the main thread.
        let (data, _) = try await URLSession.shared.data(from: url)

        // Decode the raw JSON bytes into our Swift model structs.
        // JSONDecoder maps the JSON field names to our struct properties.
        do {
            let response = try JSONDecoder().decode(AnimeResponse.self, from: data)
            return response.data
        } catch {
            throw JikanError.decodingFailure(error)
        }
    }

    // MARK: - Search Anime

    /// Searches Jikan for anime matching a user's text query.
    /// Called from the search bar on the Home screen.
    ///
    /// - Parameter query: The text the user typed into the search bar.
    /// - Returns: An array of AnimeItem models matching the search.
    /// - Throws: A JikanError if the network call or decoding fails.
    func searchAnime(query: String) async throws -> [AnimeItem] {
        // URL-encode the query so spaces and special characters don't break the URL
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "\(baseURL)/anime?q=\(encoded)&sfw=true") else {
            throw JikanError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        do {
            let response = try JSONDecoder().decode(AnimeResponse.self, from: data)

            // If Jikan returned an empty list, throw noResults
            // so the UI can show a helpful empty state message
            guard !response.data.isEmpty else {
                throw JikanError.noResults
            }

            return response.data
        } catch let error as JikanError {
            // Re-throw JikanErrors we deliberately created (like noResults)
            throw error
        } catch {
            throw JikanError.decodingFailure(error)
        }
    }

    // MARK: - Fetch Anime by Genre

    /// Fetches anime filtered by a specific genre ID.
    /// Used by the recommendation engine to serve results matching
    /// the genres the user selected during the questionnaire.
    ///
    /// Jikan genre IDs (most common ones we use):
    ///   1 = Action, 2 = Adventure, 4 = Comedy, 8 = Drama,
    ///   10 = Fantasy, 14 = Horror, 22 = Romance, 37 = Supernatural
    ///
    /// - Parameter genreID: The Jikan numeric ID for the genre.
    /// - Returns: An array of AnimeItem models in that genre.
    /// - Throws: A JikanError if the network call or decoding fails.
    func fetchAnimeByGenre(genreID: Int) async throws -> [AnimeItem] {
        guard let url = URL(string: "\(baseURL)/anime?genres=\(genreID)&order_by=score&sort=desc&sfw=true") else {
            throw JikanError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        do {
            let response = try JSONDecoder().decode(AnimeResponse.self, from: data)
            return response.data
        } catch {
            throw JikanError.decodingFailure(error)
        }
    }

    // MARK: - Fetch Anime Detail

    /// Fetches the full detail for a single anime by its Jikan/MAL ID.
    /// Called when the user taps an anime card to open the detail page.
    ///
    /// - Parameter id: The MyAnimeList ID of the anime (provided by Jikan
    ///   in every list response as `mal_id`).
    /// - Returns: A single fully-detailed AnimeItem.
    /// - Throws: A JikanError if the network call or decoding fails.
    func fetchAnimeDetail(id: Int) async throws -> AnimeItem {
        guard let url = URL(string: "\(baseURL)/anime/\(id)") else {
            throw JikanError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)

        do {
            // The detail endpoint wraps its result in a "data" key,
            // so we use AnimeDetailResponse which has a single `data` field
            let response = try JSONDecoder().decode(AnimeDetailResponse.self, from: data)
            return response.data
        } catch {
            throw JikanError.decodingFailure(error)
        }
    }
}
