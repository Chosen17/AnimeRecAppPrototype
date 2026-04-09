//
// SettingsView.swift
// AnimeRecommendationTinder-Mobile project
//
// The Settings screen — the fourth and final tab of the app.
//
// Sections:
//   1. Content — safe content toggle to filter adult-rated anime
//   2. Preferences — reset questionnaire answers
//   3. Privacy — what data the app stores and how it is used
//   4. About — app version and module information
//
// The safe content toggle uses @AppStorage so it writes directly
// to UserDefaults and is immediately read by DiscoverViewModel
// without any extra plumbing needed.
//

import SwiftUI

struct SettingsView: View {

    // Pointer - ViewModel
    @StateObject private var viewModel = SettingsViewModel()

    // Pointer - App Storage
    /// Safe content setting stored in UserDefaults.
    /// @AppStorage means any change here is immediately
    /// picked up by DiscoverViewModel which reads the same key.
    @AppStorage("safe_content_enabled") private var safeContentEnabled: Bool = true

    /// Tracks whether the questionnaire has been completed.
    /// Resetting this to false causes ContentView to show
    /// the questionnaire on the next app launch.
    @AppStorage("has_completed_questionnaire") private var hasCompletedQuestionnaire: Bool = true

    // Pointer - Body
    var body: some View {
        NavigationStack {
            List {

                // Pointer - Content Section
                Section {
                    Toggle(isOn: $safeContentEnabled) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Safe Content")
                                    .font(.body)
                                Text("Filters out anime rated R, R+ and above")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    .tint(.purple)
                } header: {
                    Text("Content")
                } footer: {
                    Text("When enabled, anime with adult ratings are hidden from the Discover and Home screens. This uses the rating data provided by MyAnimeList via the Jikan API.")
                }

                // Pointer - Preferences Section
                Section {
                    Button(action: { viewModel.requestReset() }) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Reset Genre Preferences")
                                    .foregroundStyle(.primary)
                                Text("Redo the setup questionnaire")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "arrow.counterclockwise")
                                .foregroundStyle(.purple)
                        }
                    }
                } header: {
                    Text("Preferences")
                } footer: {
                    Text("This clears your saved genre preferences, experience level and episode preference. The questionnaire will appear again the next time you open the app.")
                }

                // Pointer - Privacy Section
                Section {
                    privacyRow(
                        icon: "internaldrive.fill",
                        color: .blue,
                        title: "Data stored locally",
                        detail: "Your saved watchlist and preferences are stored only on this device using iOS UserDefaults. Nothing is sent to external servers."
                    )
                    privacyRow(
                        icon: "network",
                        color: .orange,
                        title: "Jikan API",
                        detail: "Anime data is fetched from the Jikan API (jikan.moe), an unofficial MyAnimeList API. No personal data is sent in these requests."
                    )
                    privacyRow(
                        icon: "person.slash.fill",
                        color: .purple,
                        title: "No account required",
                        detail: "This app does not require sign-up or login. No personal information is collected."
                    )
                } header: {
                    Text("Privacy & Data")
                }

                // Pointer - About Section
                Section {
                    aboutRow(label: "App", value: "Anime Recommendation Assistant")
                    aboutRow(label: "Version", value: "1.0.0")
                    aboutRow(label: "Module", value: "ITEC31041 — Mobile Platform Applications")
                    aboutRow(label: "Developer", value: "Earle Rose (N1147013)")
                    aboutRow(label: "Data source", value: "Jikan REST API v4")
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            // Confirmation alert before resetting preferences
            .alert("Reset Preferences?", isPresented: $viewModel.showingResetAlert) {
                Button("Reset", role: .destructive) {
                    viewModel.confirmReset()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will clear your saved genre preferences and show the setup questionnaire again on your next launch.")
            }
            
            // adding comfirmation so users know that their preferences have been reset
            .alert("Preference Reset", isPresented: $viewModel.didResetPreferences){
                Button("Ok"){
                    hasCompletedQuestionnaire = false
                }
            } message:{
                    Text("Your genre preferences have been cleared. The setup questionnaired will appear when you restart the app.")
                }
            }
            
            
            // When reset is confirmed, update AppStorage so
            // ContentView shows the questionnaire on next launch
            .onChange(of: viewModel.didResetPreferences) { _, didReset in
                if didReset {
                    hasCompletedQuestionnaire = false
                }
            }
        }
    }

    // Pointer - Reusable Row Components

    /// A privacy information row with an icon, title and detail text.
    private func privacyRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    /// A simple label/value row for the About section.
    private func aboutRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .multilineTextAlignment(.trailing)
        }
    }
}
