//
// SettingsView.swift
// AnimeRecommendationTinder-Mobile project
//
// The Settings screen — fourth tab of the app.
// Updated to include sign out functionality and
// pass the onSignOut callback to ContentView so
// the login screen shows immediately on sign out.
//

import SwiftUI

struct SettingsView: View {

    // Pointer - Properties
    @StateObject private var viewModel = SettingsViewModel()
    @AppStorage("safe_content_enabled") private var safeContentEnabled: Bool = true

    /// Called by ContentView when sign out is confirmed
    var onSignOut: () -> Void = {}

    // Pointer - Body
    var body: some View {
        NavigationStack {
            List {
                contentSection
                preferencesSection
                accountSection
                privacySection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .alert("Reset Preferences?", isPresented: $viewModel.showingResetAlert) {
                Button("Reset", role: .destructive) {
                    viewModel.confirmReset()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will clear your saved genre preferences and show the setup questionnaire again on your next launch.")
            }
            .alert("Preferences Reset", isPresented: $viewModel.didResetPreferences) {
                Button("OK") {}
            } message: {
                Text("Your genre preferences have been cleared. The setup questionnaire will appear when you restart the app.")
            }
        }
    }

    // Pointer - Sections

    private var contentSection: some View {
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
            Text("When enabled, anime with adult ratings are hidden from the Discover and Home screens.")
        }
    }

    private var preferencesSection: some View {
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
    }

    private var accountSection: some View {
        Section {
            Button(action: {
                APIService.shared.clearAuthData()
                UserPreferencesStorage.shared.resetPreferences()
                onSignOut()
            }) {
                Label {
                    Text("Sign Out")
                        .foregroundStyle(.red)
                } icon: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .foregroundStyle(.red)
                }
            }
        } header: {
            Text("Account")
        } footer: {
            if let username = APIService.shared.storedUsername {
                Text("Signed in as \(username)")
            }
        }
    }

    private var privacySection: some View {
        Section {
            privacyRow(
                icon: "internaldrive.fill",
                color: .blue,
                title: "Data stored locally",
                detail: "Your saved watchlist and preferences are stored on this device and your account on our server."
            )
            privacyRow(
                icon: "network",
                color: .orange,
                title: "Jikan API",
                detail: "Anime data is fetched from the Jikan API (jikan.moe). No personal data is sent in these requests."
            )
            privacyRow(
                icon: "person.slash.fill",
                color: .purple,
                title: "Account based",
                detail: "Your saved anime and preferences are tied to your account and never shared with other users."
            )
        } header: {
            Text("Privacy & Data")
        }
    }

    private var aboutSection: some View {
        Section {
            aboutRow(label: "App", value: "Anime Recommendation Assistant")
            aboutRow(label: "Version", value: "1.0.0")
            aboutRow(label: "Module", value: "ITEC31041")
            aboutRow(label: "Developer", value: "Earle Rose (N1147013)")
            aboutRow(label: "Data source", value: "Jikan REST API v4")
        } header: {
            Text("About")
        }
    }

    // Pointer - Reusable Row Components

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
