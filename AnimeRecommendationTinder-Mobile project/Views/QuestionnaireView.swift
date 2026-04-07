//
// QuestionnaireView.swift
// AnimeRecommendationTinder-Mobile project
//
// The onboarding questionnaire shown to new users.
// Walks the user through three steps:
//   Step 1 — Pick favourite genres (multi-select grid)
//   Step 2 — Select experience level with anime
//   Step 3 — Choose preferred episode count range
//
// Shown automatically on first launch via ContentView.
// Can also be re-accessed from Settings to update preferences.
//
// Uses a custom step indicator at the top to show progress.
// Each step has a Back button (except step 1) and a Next/Finish button.
//

import SwiftUI

struct QuestionnaireView: View {

    // MARK: - ViewModel
    @StateObject private var viewModel = QuestionnaireViewModel()

    /// Called by ContentView when the questionnaire finishes,
    /// so the parent can switch to showing the main TabView.
    var onComplete: () -> Void

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Progress indicator at the top
                progressBar

                // The active step's content
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        switch viewModel.currentStep {
                        case 0: genreStep
                        case 1: experienceStep
                        case 2: episodeStep
                        default: EmptyView()
                        }
                    }
                    .padding()
                }

                // Navigation buttons at the bottom
                navigationButtons
            }
            .navigationTitle("Set Up Your Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
        // When the ViewModel marks completion, tell the parent
        .onChange(of: viewModel.isComplete) { _, complete in
            if complete { onComplete() }
        }
    }

    // MARK: - Progress Bar

    /// Three dots showing which step the user is on.
    /// Filled purple dot = current step, grey = not yet reached.
    private var progressBar: some View {
        HStack(spacing: 8) {
            ForEach(0..<viewModel.totalSteps, id: \.self) { step in
                Capsule()
                    .fill(step <= viewModel.currentStep ? Color.purple : Color.secondary.opacity(0.3))
                    .frame(height: 6)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    // MARK: - Step 1: Genre Selection

    private var genreStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepHeader(
                title: "What genres do you enjoy?",
                subtitle: "Select all that appeal to you. These shape your recommendations."
            )

            // Responsive two-column grid of genre buttons
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(viewModel.availableGenres, id: \.id) { genre in
                    genreButton(id: genre.id, name: genre.name)
                }
            }
        }
    }

    /// A single tappable genre pill button.
    /// Turns solid purple when selected, outlined when not.
    private func genreButton(id: Int, name: String) -> some View {
        let isSelected = viewModel.selectedGenreIDs.contains(id)

        return Button(action: { viewModel.toggleGenre(id: id) }) {
            Text(name)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.purple : Color.clear)
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.purple : Color.secondary.opacity(0.4), lineWidth: 1.5)
                )
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    // MARK: - Step 2: Experience Level

    private var experienceStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepHeader(
                title: "How much anime have you watched?",
                subtitle: "This helps us calibrate whether to suggest classics or newer titles."
            )

            VStack(spacing: 12) {
                ForEach(viewModel.experienceOptions, id: \.value) { option in
                    optionCard(
                        label: option.label,
                        description: option.description,
                        isSelected: viewModel.experienceLevel == option.value
                    ) {
                        viewModel.experienceLevel = option.value
                    }
                }
            }
        }
    }

    // MARK: - Step 3: Episode Preference

    private var episodeStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            stepHeader(
                title: "How long do you want your anime?",
                subtitle: "We will prioritise series that fit your preferred commitment level."
            )

            VStack(spacing: 12) {
                ForEach(viewModel.episodeOptions, id: \.value) { option in
                    optionCard(
                        label: option.label,
                        description: option.description,
                        isSelected: viewModel.episodePreference == option.value
                    ) {
                        viewModel.episodePreference = option.value
                    }
                }
            }
        }
    }

    // MARK: - Reusable Components

    /// Consistent heading and subtitle for each step.
    private func stepHeader(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    /// A selectable card used for single-choice options (steps 2 and 3).
    /// Highlighted in purple when selected.
    private func optionCard(label: String, description: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                // Selection indicator circle
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.purple : Color.secondary.opacity(0.4), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(Color.purple)
                            .frame(width: 13, height: 13)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(14)
            .background(isSelected ? Color.purple.opacity(0.08) : Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.purple : Color.secondary.opacity(0.2), lineWidth: 1.5)
            )
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    // MARK: - Navigation Buttons

    /// Back and Next/Finish buttons shown at the bottom of every step.
    private var navigationButtons: some View {
        HStack(spacing: 12) {
            // Back button — hidden on step 0
            if viewModel.currentStep > 0 {
                Button(action: { viewModel.previousStep() }) {
                    Text("Back")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.secondary.opacity(0.12))
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            // Next or Finish button
            Button(action: { viewModel.nextStep() }) {
                Text(viewModel.currentStep == viewModel.totalSteps - 1 ? "Finish" : "Next")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.purple)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 24)
        .padding(.top, 12)
    }
}
