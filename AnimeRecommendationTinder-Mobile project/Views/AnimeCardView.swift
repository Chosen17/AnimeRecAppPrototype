//
// AnimeCardView.swift
// AnimeRecommendationTinder-Mobile project
//
// A reusable card component that displays a single anime's
// cover image, title, score, and genre tags.
//
// Used in:
//   - HomeView (trending and search results list)
//   - Future: DiscoverView (swipe card stack)
//
// Accepts an AnimeItem and renders it — no network calls,
// no ViewModel needed here. Pure display component.
//

import SwiftUI

struct AnimeCardView: View {

    // The anime data this card should display
    let anime: AnimeItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            // MARK: Cover Image
            // AsyncImage handles downloading and caching the image URL.
            // Shows a placeholder while loading and a fallback if it fails.
            AsyncImage(url: URL(string: anime.images.jpg.imageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    // While the image is downloading — show a grey placeholder
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.2))
                        .overlay(ProgressView())
                case .success(let image):
                    // Image loaded successfully
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    // Image failed to load — show a generic icon
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundStyle(.secondary)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 80, height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // MARK: Text Info
            VStack(alignment: .leading, spacing: 6) {

                // Anime title — prefer English title if available
                Text(anime.titleEnglish ?? anime.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                // Score and episode count on one line
                HStack(spacing: 8) {
                    if let score = anime.score {
                        Label("\(String(format: "%.1f", score))", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    if let episodes = anime.episodes {
                        Text("\(episodes) eps")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if let status = anime.status {
                        Text(status)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Genre tags — show up to 3 to avoid overflow
                if !anime.genres.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(anime.genres.prefix(3), id: \.malId) { genre in
                            Text(genre.name)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(Color.purple.opacity(0.15))
                                .foregroundStyle(Color.purple)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}
