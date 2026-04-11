//
// SwipeCardView.swift
// AnimeRecommendationTinder-Mobile project
//
// A single anime card displayed in the swipe stack on DiscoverView.
// Shows the cover image as a full-card background with a gradient
// overlay at the bottom containing the title, score and genres.
//
// Updated after user testing round 1 (User: JC):
// Added tap-to-reveal synopsis overlay so users can read a
// description before deciding to swipe right or left.
// This directly addressed the feedback that new anime viewers
// needed more information before making a decision.
//

import SwiftUI

struct SwipeCardView: View {

    let anime: AnimeItem

    // Pointer - State
    /// Controls whether the synopsis overlay is visible.
    /// Toggled by tapping the info button on the card.
    @State private var showingSynopsis: Bool = false

    var body: some View {
        ZStack(alignment: .bottom) {

            // Pointer - Cover Image
            AsyncImage(url: URL(string:
                anime.images.jpg.largeImageUrl ??
                anime.images.jpg.imageUrl ?? ""
            )) { phase in
                switch phase {
                case .empty:
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.secondary.opacity(0.2))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    RoundedRectangle(cornerRadius: 20)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 20))

            // Pointer - Gradient Overlay
            LinearGradient(
                colors: [.clear, .black.opacity(0.85)],
                startPoint: .center,
                endPoint: .bottom
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))

            // Pointer - Synopsis Overlay
            // Slides up from the bottom when the info button is tapped.
            // Gives the user a peek at the synopsis before deciding.
            if showingSynopsis, let synopsis = anime.synopsis {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Synopsis")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Spacer()
                        // Close button to dismiss the synopsis
                        Button(action: { showingSynopsis = false }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.white.opacity(0.8))
                                .font(.system(size: 22))
                        }
                    }
                    ScrollView {
                        Text(synopsis)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                            .lineSpacing(4)
                    }
                    .frame(maxHeight: 180)
                }
                .padding(16)
                .background(.black.opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            // Pointer - Info Panel
            VStack(alignment: .leading, spacing: 8) {

                // Title
                Text(anime.titleEnglish ?? anime.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(2)

                // Score, episodes and status
                HStack(spacing: 12) {
                    if let score = anime.score {
                        Label(String(format: "%.1f", score), systemImage: "star.fill")
                            .font(.subheadline)
                            .foregroundStyle(.yellow)
                    }
                    if let episodes = anime.episodes {
                        Text("\(episodes) eps")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    if let status = anime.status {
                        Text(status)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    Spacer()

                    // Info button — tapping reveals the synopsis overlay
                    // Added in response to user testing feedback (JC, Round 1)
                    if anime.synopsis != nil {
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                showingSynopsis = true
                            }
                        }) {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.white.opacity(0.9))
                                .font(.system(size: 22))
                        }
                    }
                }

                // Genre tags
                if !anime.genres.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(anime.genres.prefix(3), id: \.malId) { genre in
                            Text(genre.name)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.white.opacity(0.2))
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .frame(height: 520)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}
