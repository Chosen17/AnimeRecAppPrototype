//
// AnimeDetailView.swift
// AnimeRecommendationTinder-Mobile project
//
// The full detail screen for a single anime.
// Opened when the user taps any anime card on the Home screen.
//
// Displays:
//   - Large cover image at the top
//   - Title (English and Japanese)
//   - Score, episode count, status, year, rating
//   - Full synopsis
//   - All genre tags
//   - Save to watchlist button
//
// Data is fetched from Jikan's /anime/{id} endpoint via
// AnimeDetailViewModel. The basic AnimeItem passed in from
// the card is used immediately to show a title while loading,
// preventing a blank screen while the full detail loads.
//

import SwiftUI

struct AnimeDetailView: View {

    // MARK: - Properties

    /// Basic anime data passed in from the card tapped on HomeView.
    /// Used to show the title and cover immediately while full detail loads.
    let anime: AnimeItem

    /// The ViewModel that fetches full detail data for this anime.
    /// Initialised with the anime's MAL ID so it knows what to fetch.
    @StateObject private var viewModel: AnimeDetailViewModel

    // MARK: - Initialiser

    /// Custom init needed because @StateObject requires the ViewModel
    /// to be created with a parameter (the animeID).
    init(anime: AnimeItem) {
        self.anime = anime
        // _viewModel uses the underscore prefix to access the
        // @StateObject wrapper directly during initialisation
        _viewModel = StateObject(wrappedValue: AnimeDetailViewModel(animeID: anime.id))
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: Hero Image
                // Large cover image at the top of the screen.
                // Uses the large image URL from Jikan if available,
                // falls back to the standard size.
                AsyncImage(url: URL(string:
                    viewModel.anime?.images.jpg.largeImageUrl ??
                    anime.images.jpg.largeImageUrl ??
                    anime.images.jpg.imageUrl ?? ""
                )) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.secondary)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 320)
                .clipped()

                // MARK: Content
                VStack(alignment: .leading, spacing: 16) {

                    // Title block — show while loading using passed-in anime data
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.anime?.titleEnglish ?? anime.titleEnglish ?? anime.title)
                            .font(.title2)
                            .fontWeight(.bold)

                        if let japanese = viewModel.anime?.titleJapanese ?? anime.titleJapanese {
                            Text(japanese)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    // Stats row — score, episodes, year, content rating
                    statsRow

                    // Genre tags — all genres shown on detail page (not capped at 3)
                    let genres = viewModel.anime?.genres ?? anime.genres
                    if !genres.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(genres, id: \.malId) { genre in
                                    Text(genre.name)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.purple.opacity(0.15))
                                        .foregroundStyle(Color.purple)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    // Synopsis
                    if let synopsis = viewModel.anime?.synopsis ?? anime.synopsis {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Synopsis")
                                .font(.headline)
                            Text(synopsis)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .lineSpacing(4)
                        }
                    }

                    // Loading indicator for when full detail is still fetching
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView("Loading details...")
                            Spacer()
                        }
                        .padding()
                    }

                    // Error message if detail fetch failed
                    if let error = viewModel.errorMessage {
                        Text("Could not load full details: \(error)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding()
                    }
                }
                .padding()
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        // Bookmark button in the top-right corner to save/unsave
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { viewModel.toggleSaved() }) {
                    Image(systemName: viewModel.isSaved ? "bookmark.fill" : "bookmark")
                        .foregroundStyle(viewModel.isSaved ? .purple : .primary)
                }
                // Accessibility label so VoiceOver users know what the button does
                .accessibilityLabel(viewModel.isSaved ? "Remove from saved" : "Save anime")
            }
        }
        // Fetch full detail when this screen appears
        .task {
            await viewModel.loadDetail()
        }
    }

    // MARK: - Subviews

    /// A horizontal row showing the key stats for this anime.
    private var statsRow: some View {
        let detail = viewModel.anime ?? anime

        return HStack(spacing: 16) {
            // Score
            if let score = detail.score {
                Label("\(String(format: "%.1f", score))", systemImage: "star.fill")
                    .font(.subheadline)
                    .foregroundStyle(.orange)
            }

            // Episodes
            if let eps = detail.episodes {
                Label("\(eps) eps", systemImage: "play.rectangle")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Year
            if let year = detail.year {
                Label(String(year), systemImage: "calendar") // had to change the formatting so that the year will appear as "2023" and not "2,023"
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Content rating (PG, PG-13, R etc.)
            if let rating = detail.rating {
                // Show just the rating code before the dash e.g. "PG-13" from "PG-13 - Teens 13 or older"
                let shortRating = rating.components(separatedBy: " - ").first ?? rating
                Text(shortRating)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.secondary.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
    }
}
