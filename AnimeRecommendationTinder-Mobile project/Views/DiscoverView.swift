//
// DiscoverView.swift
// AnimeRecommendationTinder-Mobile project
//
// The Discover screen — the swipe-based anime recommendation interface.
// This is the core feature of the app, directly addressing the problem
// of choice overload described in the CW1 proposal.
//
// The user sees a stack of anime cards. They can:
//   - Swipe right (or tap the heart button) to save an anime
//   - Swipe left (or tap the X button) to skip it
//   - Tap the card to see a brief info overlay
//
// Cards are loaded from Jikan filtered by the user's genre preferences
// saved during the questionnaire. The stack refills automatically
// when it runs low.
//
// The swipe mechanic uses DragGesture to track finger movement.
// A card dragged past a threshold snaps off screen with an animation.
// A card not dragged far enough springs back to centre.
//

import SwiftUI

struct DiscoverView: View {

    // Pointer - ViewModel
    @StateObject private var viewModel = DiscoverViewModel()

    // Pointer - Constants
    /// How far the user must drag before the card counts as a swipe decision.
    private let swipeThreshold: CGFloat = 120

    // Pointer - Body
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading {
                    loadingView
                } else if let error = viewModel.errorMessage {
                    errorView(message: error)
                } else if viewModel.cardStack.isEmpty {
                    emptyView
                } else {
                    cardStackView
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
        }
        .task {
            await viewModel.loadRecommendations()
        }
    }

    // Pointer - Card Stack

    /// Renders the stack of swipeable anime cards.
    /// The top card (last in array) is fully interactive.
    /// Cards beneath it are shown at reduced scale for a stacked effect.
    private var cardStackView: some View {
        VStack(spacing: 0) {
            ZStack {
                // Show up to 3 cards in the stack for the layered effect
                ForEach(Array(viewModel.cardStack.suffix(3).enumerated()), id: \.element.id) { index, anime in
                    let isTop = anime.id == viewModel.cardStack.last?.id
                    let stackIndex = viewModel.cardStack.suffix(3).count - 1 - index

                    SwipeCardView(anime: anime)
                        // Cards below the top are scaled down and offset
                        // to create a visual depth effect
                        .scaleEffect(isTop ? 1.0 : 1.0 - CGFloat(stackIndex) * 0.04)
                        .offset(y: isTop ? 0 : CGFloat(stackIndex) * 10)
                        .offset(isTop ? viewModel.dragOffset : .zero)
                        // Rotate the top card as it's dragged — feels natural
                        .rotationEffect(
                            isTop ? .degrees(Double(viewModel.dragOffset.width / 20)) : .zero
                        )
                        .gesture(isTop ? dragGesture : nil)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.dragOffset)
                        .zIndex(isTop ? 1 : 0)
                }
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal)

            // Like/Skip action buttons beneath the card stack
            actionButtons
                .padding(.bottom, 24)
        }
    }

    // Pointer - Drag Gesture

    /// The DragGesture that drives the swipe mechanic.
    /// Tracks finger movement and either confirms a swipe or snaps back.
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                // Update the offset in real time as the finger moves
                viewModel.dragOffset = value.translation
            }
            .onEnded { value in
                let width = value.translation.width

                if width > swipeThreshold {
                    // Swiped far enough to the right — like it
                    withAnimation(.easeOut(duration: 0.3)) {
                        // Fly the card off screen to the right
                        viewModel.dragOffset = CGSize(width: 600, height: value.translation.height)
                    }
                    // Small delay so the animation plays before removing the card
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.LikeTopCard()
                    }
                } else if width < -swipeThreshold {
                    // Swiped far enough to the left — skip it
                    withAnimation(.easeOut(duration: 0.3)) {
                        viewModel.dragOffset = CGSize(width: -600, height: value.translation.height)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        viewModel.skipTopCard()
                    }
                } else {
                    // Not dragged far enough — spring the card back to centre
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        viewModel.dragOffset = .zero
                    }
                }
            }
    }

    // Pointer - Action Buttons

    /// The X (skip) and heart (like) buttons beneath the card stack.
    /// Provide an alternative to swiping for accessibility.
    private var actionButtons: some View {
        HStack(spacing: 48) {
            // Skip button
            Button(action: {
                withAnimation(.easeOut(duration: 0.3)) {
                    viewModel.dragOffset = CGSize(width: -600, height: 0)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    viewModel.skipTopCard()
                }
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.red)
                    .frame(width: 64, height: 64)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Circle())
            }

            // Like button
            Button(action: {
                withAnimation(.easeOut(duration: 0.3)) {
                    viewModel.dragOffset = CGSize(width: 600, height: 0)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    viewModel.LikeTopCard()
                }
            }) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.purple)
                    .frame(width: 64, height: 64)
                    .background(Color.purple.opacity(0.1))
                    .clipShape(Circle())
            }
        }
        .padding(.top, 24)
    }

    // Pointer - State Views

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Finding anime for you...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Could not load recommendations")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Try Again") {
                Task { await viewModel.loadRecommendations() }
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
    }

    /// Shown when all cards have been swiped through.
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.purple)
            Text("You've seen everything!")
                .font(.title3)
                .fontWeight(.semibold)
            Text("Check your saved list or reload for more recommendations.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Load More") {
                Task { await viewModel.loadRecommendations() }
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
        }
    }
}
