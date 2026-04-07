//
// AnimeItem.swift
// AnimeRecommendationTinder-Mobile project
//
// Defines the data models that map directly to the JSON
// responses returned by the Jikan API.
//
// 'Codable' means Swift can automatically convert JSON → struct
// and struct → JSON without us writing any parsing code manually.
//
// 'Identifiable' means SwiftUI can use these in ForEach loops
// and List views without needing an explicit id parameter.
//
// 'Hashable' means these can be stored in Sets and used as
// dictionary keys — needed for our saved/liked anime storage.
//

import Foundation

// MARK: - AnimeItem

/// Represents a single anime entry returned by Jikan.
/// Every property name matches the JSON key from the API
/// (using CodingKeys where Swift naming conventions differ).
struct AnimeItem: Codable, Identifiable, Hashable {

    // Jikan calls this 'mal_id' — the MyAnimeList unique ID for this anime
    let id: Int

    // The anime's canonical title (usually the romanised Japanese title)
    let title: String

    // Optional English title — not all anime have official English names
    let titleEnglish: String?

    // Optional Japanese title in kanji/hiragana
    let titleJapanese: String?

    // Nested struct containing the cover image URL
    let images: AnimeImages

    // A text summary of the anime's story (may be nil for obscure entries)
    let synopsis: String?

    // Average user score on MyAnimeList out of 10 (optional — unscored anime exist)
    let score: Double?

    // Total number of episodes (nil if currently airing and unknown)
    let episodes: Int?

    // Airing status e.g. "Finished Airing", "Currently Airing", "Not yet aired"
    let status: String?

    // Content rating e.g. "PG-13", "R - 17+", "R+" — used for safe content filtering
    let rating: String?

    // The year this anime started airing
    let year: Int?

    // Array of genre objects attached to this anime
    let genres: [AnimeGenre]

    // Maps JSON snake_case keys to Swift camelCase property names
    enum CodingKeys: String, CodingKey {
        case id = "mal_id"
        case title
        case titleEnglish = "title_english"
        case titleJapanese = "title_japanese"
        case images
        case synopsis
        case score
        case episodes
        case status
        case rating
        case year
        case genres
    }
}

// MARK: - AnimeImages

/// Holds the URLs for the different image sizes Jikan provides.
/// We use 'jpg' for standard quality and 'webp' as an alternative.
struct AnimeImages: Codable, Hashable {
    let jpg: AnimeImageURLs
}

/// The actual URL strings for a given image format.
struct AnimeImageURLs: Codable, Hashable {
    // Standard size cover image — used on cards
    let imageUrl: String?

    // Larger version — used on the detail page
    let largeImageUrl: String?

    enum CodingKeys: String, CodingKey {
        case imageUrl = "image_url"
        case largeImageUrl = "large_image_url"
    }
}

// MARK: - AnimeGenre

/// Represents a single genre tag attached to an anime.
/// Each genre has a Jikan ID (used for filtering) and a display name.
struct AnimeGenre: Codable, Hashable {
    let malId: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case malId = "mal_id"
        case name
    }
}

// MARK: - API Response Wrappers

/// Wraps a list of AnimeItem objects as returned by Jikan list endpoints.
/// Jikan always wraps array results in a top-level "data" key.
struct AnimeResponse: Codable {
    let data: [AnimeItem]
}

/// Wraps a single AnimeItem as returned by Jikan detail endpoints.
/// e.g. GET /anime/{id} returns { "data": { ...single anime... } }
struct AnimeDetailResponse: Codable {
    let data: AnimeItem
}
