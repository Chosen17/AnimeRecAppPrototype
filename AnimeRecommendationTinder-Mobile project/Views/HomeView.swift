//
// HomeView.swift
// AnimeRecommendationTinder-Mobile project
//
// The Home screen — the first tab the user sees.
//
// Displays:
//   - A searchable list of trending anime (from Jikan's /top/anime endpoint)
//   - Search results when the user types in the search bar
//   - A loading spinner while data is being fetched
//   - An error message if the network call fails
//
// This View never calls the API directly.
// It only reads from and writes to HomeViewModel.
// That separation is the core idea of MVVM.
//

import SwiftUI

struct HomeView: View {

    // MARK: - ViewModel

    /// The ViewModel that drives this screen.
    /// @StateObject means SwiftUI creates and owns this instance —
    /// it lives as long as HomeView is on screen.
    @StateObject private var viewModel = HomeViewModel()

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.animeList.isEmpty {
                    // Show a full-screen spinner only on the very first load
                    // (subsequent loads show the old list while refreshing)
                    loadingView
                } else if let error = viewModel.errorMessage, viewModel.animeList.isEmpty {
                    // Show an error message if loading failed and we have no data to show
                    errorView(message: error)
                } else {
                    // Show the anime list
                    animeListView
                }
            }
            .navigationTitle("Discover Anime")
            .navigationBarTitleDisplayMode(.large)
            // .searchable connects the system search bar to our ViewModel's searchText
            .searchable(text: $viewModel.searchText, prompt: "Search anime...")
            // Fire a search whenever the text changes
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.performSearch()
            }
        }
        // Load trending anime the moment this screen appears
        .task {
            await viewModel.loadTopAnime()
        }
    }

    // MARK: - Subviews

    /// The scrollable list of anime cards.
    private var animeListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Show how many results were found when searching
                if !viewModel.searchText.isEmpty {
                    Text("\(viewModel.animeList.count) results for \"\(viewModel.searchText)\"")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                }

                // One card per anime in the list
                ForEach(viewModel.animeList) { anime in
                    // NavigationLink will push AnimeDetailView when tapped
                    // (AnimeDetailView will be built on Day 4)
                    NavigationLink(destination: AnimeDetailView(anime: anime)) {
                        AnimeCardView(anime: anime)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical)
        }
    }

    /// Full-screen loading spinner shown on first load.
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading anime...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Error message shown when a network call fails.
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Something went wrong")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            // Let the user retry without having to restart the app
            Button("Try Again") {
                Task { await viewModel.loadTopAnime() }
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
