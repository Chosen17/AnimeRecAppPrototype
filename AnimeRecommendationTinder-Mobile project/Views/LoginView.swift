//
// LoginView.swift
// AnimeRecommendationTinder-Mobile project
//
// The login screen shown to returning users.
// Allows switching to SignUpView for new users.
//
// On successful login ContentView switches to the
// questionnaire (if first time) or main TabView.
//

import SwiftUI

struct LoginView: View {

    // Pointer - ViewModel
    @StateObject private var viewModel = AuthViewModel()

    /// Called by ContentView when auth succeeds.
    var onAuthenticated: () -> Void

    /// Controls whether the Sign Up sheet is showing.
    @State private var showingSignUp = false

    // Pointer - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                Spacer()

                // App icon and title
                VStack(spacing: 8) {
                    Image(systemName: "play.rectangle.on.rectangle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.purple)

                    Text("Anime Recommendation")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Sign in to your account")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Input fields
                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()

                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal)

                // Error message
                if let error = viewModel.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Login button
                Button(action: {
                    Task { await viewModel.login() }
                }) {
                    Group {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Sign In")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.purple)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .disabled(viewModel.isLoading)

                // Sign up link
                Button(action: { showingSignUp = true }) {
                    Text("Don't have an account? ")
                        .foregroundStyle(.secondary)
                    + Text("Sign Up")
                        .foregroundStyle(.purple)
                        .fontWeight(.semibold)
                }
                .font(.subheadline)

                Spacer()
            }
            .navigationTitle("")
        }
        // When login succeeds tell ContentView
        .onChange(of: viewModel.isAuthenticated) { _, authenticated in
            if authenticated { onAuthenticated() }
        }
        // Sign up sheet
        .sheet(isPresented: $showingSignUp) {
            SignUpView {
                showingSignUp = false
                onAuthenticated()
            }
        }
    }
}
