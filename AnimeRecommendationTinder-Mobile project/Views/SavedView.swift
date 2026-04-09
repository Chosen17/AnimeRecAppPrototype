//
// SavedView.swift
// AnimeRecommendationTinder-Mobile project
//
// The Saved/Watchlist screen — the third tab of the app.
// Displays all anime the user has bookmarked from the detail
// screen or swiped right on in the Discover screen.
//
// Features:
//   - Scrollable list of saved anime using AnimeCardView
//   - Swipe to delete a row to remove an anime from the list
//   - Tapping a card opens AnimeDetailView
//   - Empty state message when nothing has been saved yet
//   - List refreshes every time the tab is opened
//

import SwiftUI

struct SavedView: View {

    // Pointer - ViewModel
    @StateObject private var viewModel = SavedViewModel()

    // Pointer - Body
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.savedAnime.isEmpty {
                    emptyView
                } else {
                    savedListView
                }
            }
            .navigationTitle("My Watchlist")
            .navigationBarTitleDisplayMode(.large)
        }
        // Reload the saved list every time this tab becomes visible.
        // This ensures changes made on the Detail or Discover screens
        // are immediately reflected here without a manual refresh.
        .onAppear {
            viewModel.loadSaved()
        }
    }

    // Pointer - Saved List

    /// Scrollable list of saved anime cards with swipe-to-delete.
    private var savedListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {

                // Count header showing how many anime are saved
                Text("\(viewModel.savedAnime.count) anime saved")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                ForEach(viewModel.savedAnime) { anime in
                    ZStack(alignment: .trailing) {

                        // Navigate to detail view on tap
                        NavigationLink(destination: AnimeDetailView(anime: anime)) {
                            AnimeCardView(anime: anime)
                        }
                        .buttonStyle(.plain)

                        // Swipe-to-delete button on the right side
                        // Using a ZStack overlay approach for custom
                        // delete styling rather than List's default
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.3)) {
                                viewModel.remove(animeID: anime.id)
                            }
                        }) {
                            Image(systemName: "trash.fill")
                                .foregroundStyle(.white)
                                .padding(12)
                                .background(Color.red)
                                .clipShape(Circle())
                        }
                        .padding(.trailing, 24)
                    }
                }
            }
            .padding(.vertical)
        }
    }

    // Pointer - State Views

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading your watchlist...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Shown when the user has not saved any anime yet.
    /// Gives a friendly prompt directing them to the Discover tab.
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bookmark.slash")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text("Nothing saved yet")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Swipe right on anime in the Discover tab or tap the bookmark on any anime to save it here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
