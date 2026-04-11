//
// SwipeCardView.swift
// AnimeRecommendationTinder-Mobile project
//
// A single anime card displayed in the swipe stack on DiscoverView.
//
// Updated after user testing round 1 (User: JC):
// Synopsis now appears as a proper bottom sheet modal that slides
// up over the entire card, eliminating the clash with the card's
// title and info panel that occurred with the previous overlay approach.
//

import SwiftUI

struct SwipeCardView: View {

    let anime: AnimeItem

    // Pointer - State
    /// Controls whether the synopsis bottom sheet is presented.
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

            // Pointer - Info Panel
            VStack(alignment: .leading, spacing: 8) {

                Text(anime.titleEnglish ?? anime.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(2)

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

                    // Info button — tapping presents the synopsis as
                    // a clean bottom sheet separate from the card info
                    if anime.synopsis != nil {
                        Button(action: { showingSynopsis = true }) {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(.white.opacity(0.9))
                                .font(.system(size: 22))
                        }
                    }
                }

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
        // Pointer - Synopsis Bottom Sheet
        // Presented as a proper modal sheet that slides up
        // independently of the card, so there is no overlap
        // with the title or info panel beneath.
        .sheet(isPresented: $showingSynopsis) {
            SynopsisSheetView(anime: anime)
                // Detents control how tall the sheet can be.
                // .medium shows roughly half the screen — enough
                // for most synopses without covering the whole card.
                // .large lets the user pull it up further if needed.
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(24)
        }
    }
}

// Pointer - Synopsis Sheet View
/// The content of the bottom sheet shown when the user taps
/// the info button on a swipe card. Presented independently
/// of the card so there is no visual clash with card elements.
struct SynopsisSheetView: View {

    let anime: AnimeItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    // Mini header showing cover and title
                    // so the user knows which anime this synopsis is for
                    HStack(alignment: .top, spacing: 14) {
                        AsyncImage(url: URL(string:
                            anime.images.jpg.imageUrl ?? ""
                        )) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 70, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            default:
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(width: 70, height: 100)
                            }
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text(anime.titleEnglish ?? anime.title)
                                .font(.headline)
                                .lineLimit(3)

                            if let score = anime.score {
                                Label(String(format: "%.1f", score), systemImage: "star.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(.orange)
                            }

                            if !anime.genres.isEmpty {
                                Text(anime.genres.prefix(3).map { $0.name }.joined(separator: " · "))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Divider()

                    // Full synopsis text
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Synopsis")
                            .font(.headline)

                        Text(anime.synopsis ?? "No synopsis available.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .lineSpacing(5)
                    }
                }
                .padding()
            }
            .navigationTitle("About this anime")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }
                        .foregroundStyle(.purple)
                }
            }
        }
    }
}
