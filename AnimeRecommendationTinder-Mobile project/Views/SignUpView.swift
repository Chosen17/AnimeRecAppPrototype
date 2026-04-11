//
// SignUpView.swift
// AnimeRecommendationTinder-Mobile project
//
// The sign up screen for new users.
// Presented as a sheet from LoginView.
//
// On successful signup the user is taken directly
// to the questionnaire to set up their preferences.
//

import SwiftUI

struct SignUpView: View {

    // Pointer - ViewModel
    @StateObject private var viewModel = AuthViewModel()

    /// Called when signup succeeds — dismisses sheet and proceeds.
    var onAuthenticated: () -> Void

    @Environment(\.dismiss) private var dismiss

    // Pointer - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {

                Spacer()

                VStack(spacing: 8) {
                    Image(systemName: "person.badge.plus.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.purple)

                    Text("Create Account")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Join and get personalised anime recommendations")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // Input fields
                VStack(spacing: 16) {
                    TextField("Username", text: $viewModel.username)
                        .textFieldStyle(.roundedBorder)
                        .autocorrectionDisabled()

                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()

                    SecureField("Password (min. 6 characters)", text: $viewModel.password)
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

                // Sign up button
                Button(action: {
                    Task { await viewModel.signup() }
                }) {
                    Group {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Create Account")
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

                // Back to login
                Button(action: { dismiss() }) {
                    Text("Already have an account? ")
                        .foregroundStyle(.secondary)
                    + Text("Sign In")
                        .foregroundStyle(.purple)
                        .fontWeight(.semibold)
                }
                .font(.subheadline)

                Spacer()
            }
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
        .onChange(of: viewModel.isAuthenticated) { _, authenticated in
            if authenticated { onAuthenticated() }
        }
    }
}
