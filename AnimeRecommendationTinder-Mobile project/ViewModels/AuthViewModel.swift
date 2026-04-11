//
// AuthViewModel.swift
// AnimeRecommendationTinder-Mobile project
//
// The ViewModel for the Login and Sign Up screens.
// Coordinates between the auth Views and APIService.
//
// After a successful login or signup:
//   - The auth token is saved to UserDefaults via APIService
//   - isAuthenticated is set to true
//   - ContentView switches to the main app
//

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {

    // Pointer - Published Properties
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isAuthenticated: Bool = false

    // Pointer - Public Functions

    /// Attempts to log in with the current email and password.
    func login() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter your email and password."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await APIService.shared.login(
                email: email,
                password: password
            )
            // Save the token so the app stays logged in
            APIService.shared.saveAuthData(
                token: response.token,
                userID: response.userId,
                username: response.username
            )
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Creates a new account with the current email, password and username.
    func signup() async {
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }

        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await APIService.shared.signup(
                email: email,
                password: password,
                username: username
            )
            APIService.shared.saveAuthData(
                token: response.token,
                userID: response.userId,
                username: response.username
            )
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
