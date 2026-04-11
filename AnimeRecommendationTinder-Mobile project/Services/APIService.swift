//
// APIService.swift
// AnimeRecommendationTinder-Mobile project
//
// Handles all communication with the Rails backend API.
// Running locally at http://127.0.0.1:3000 during development.
//
// Responsibilities:
//   - User signup and login
//   - Saving and loading preferences per user account
//   - Saving, loading and removing anime from the server watchlist
//
// All functions are async/await and throw APIError on failure.
// The auth token is read from UserDefaults where it was stored
// after login — sent in the Authorization header of every
// authenticated request.
//

import Foundation

// Pointer - Error Type
enum APIError: Error, LocalizedError {
    case invalidURL
    case networkFailure(Error)
    case serverError(Int)
    case decodingFailure
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid API URL."
        case .networkFailure(let e): return "Network error: \(e.localizedDescription)"
        case .serverError(let code): return "Server returned error \(code)."
        case .decodingFailure: return "Could not read the server response."
        case .notAuthenticated: return "You are not logged in."
        }
    }
}

// Pointer - Response Models
// These structs decode the JSON responses from the Rails API.

struct AuthResponse: Codable {
    let token: String
    let userId: Int
    let username: String

    enum CodingKeys: String, CodingKey {
        case token
        case userId = "user_id"
        case username
    }
}

struct PreferencesResponse: Codable {
    let genreIds: [Int]
    let experienceLevel: String
    let episodePreference: String

    enum CodingKeys: String, CodingKey {
        case genreIds = "genre_ids"
        case experienceLevel = "experience_level"
        case episodePreference = "episode_preference"
    }
}

struct SavedAnimeResponse: Codable {
    let id: Int
    let malId: Int
    let title: String
    let imageUrl: String?
    let score: Double?
    let episodes: Int?
    let status: String?

    enum CodingKeys: String, CodingKey {
        case id
        case malId = "mal_id"
        case title
        case imageUrl = "image_url"
        case score
        case episodes
        case status
    }
}

// Pointer - APIService
class APIService {

    // Singleton so any part of the app can call the API
    static let shared = APIService()
    private init() {}

    // Base URL for the Rails server running locally
    private let baseURL = "http://127.0.0.1:3000/api"

    // UserDefaults key for storing the auth token
    private let tokenKey = "auth_token"
    private let userIDKey = "auth_user_id"
    private let usernameKey = "auth_username"

    // Pointer - Token Management

    /// Saves the auth token and user info after login or signup.
    func saveAuthData(token: String, userID: Int, username: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(userID, forKey: userIDKey)
        UserDefaults.standard.set(username, forKey: usernameKey)
    }

    /// Clears the auth token on logout.
    func clearAuthData() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: userIDKey)
        UserDefaults.standard.removeObject(forKey: usernameKey)
    }

    /// Returns true if a token is stored — user is logged in.
    var isLoggedIn: Bool {
        UserDefaults.standard.string(forKey: tokenKey) != nil
    }

    /// Returns the stored username for display.
    var storedUsername: String? {
        UserDefaults.standard.string(forKey: usernameKey)
    }

    /// Returns the stored token for authenticated requests.
    private var token: String? {
        UserDefaults.standard.string(forKey: tokenKey)
    }

    // Pointer - Auth Endpoints

    /// Creates a new user account on the Rails backend.
    /// - Returns: AuthResponse containing token and user details.
    func signup(email: String, password: String, username: String) async throws -> AuthResponse {
        let body = ["email": email, "password": password, "username": username]
        return try await post(endpoint: "/signup", body: body, authenticated: false)
    }

    /// Logs in with existing credentials.
    /// - Returns: AuthResponse containing token and user details.
    func login(email: String, password: String) async throws -> AuthResponse {
        let body = ["email": email, "password": password]
        return try await post(endpoint: "/login", body: body, authenticated: false)
    }

    // Pointer - Preferences Endpoints

    /// Saves the user's questionnaire answers to the backend.
    /// Ensures preferences are tied to the user's account, not just the device.
    func savePreferences(genreIDs: [Int], experienceLevel: String, episodePreference: String) async throws {
        let body: [String: Any] = [
            "genre_ids": genreIDs,
            "experience_level": experienceLevel,
            "episode_preference": episodePreference
        ]
        let _: [String: String] = try await put(endpoint: "/preferences", body: body)
    }

    /// Loads the user's preferences from the backend.
    /// Called on login so preferences sync across devices.
    func loadPreferences() async throws -> PreferencesResponse {
        return try await get(endpoint: "/preferences")
    }

    // Pointer - Saved Anime Endpoints

    /// Saves an anime to the user's server-side watchlist.
    func saveAnime(anime: AnimeItem) async throws {
        let body: [String: Any] = [
            "mal_id": anime.id,
            "title": anime.titleEnglish ?? anime.title,
            "image_url": anime.images.jpg.imageUrl ?? "",
            "score": anime.score ?? 0,
            "episodes": anime.episodes ?? 0,
            "status": anime.status ?? "",
            "genres": anime.genres.map { $0.name }.joined(separator: ",")
        ]
        let _: SavedAnimeResponse = try await post(endpoint: "/saved_animes", body: body, authenticated: true)
    }

    /// Removes an anime from the user's server-side watchlist by MAL ID.
    func removeAnime(malID: Int) async throws {
        try await delete(endpoint: "/saved_animes/\(malID)")
    }

    /// Loads all anime saved to the user's server-side watchlist.
    func loadSavedAnimes() async throws -> [SavedAnimeResponse] {
        return try await get(endpoint: "/saved_animes")
    }

    // Pointer - Private HTTP Helpers

    private func post<T: Codable>(endpoint: String, body: [String: Any], authenticated: Bool) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if authenticated, let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        return try await perform(request)
    }

    private func put<T: Codable>(endpoint: String, body: [String: Any]) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        return try await perform(request)
    }

    private func get<T: Codable>(endpoint: String) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return try await perform(request)
    }

    private func delete(endpoint: String) async throws {
        guard let url = URL(string: baseURL + endpoint) else { throw APIError.invalidURL }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? 0)
        }
    }

    private func perform<T: Codable>(_ request: URLRequest) async throws -> T {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError((response as? HTTPURLResponse)?.statusCode ?? 0)
            }
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw APIError.decodingFailure
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkFailure(error)
        }
    }
}
