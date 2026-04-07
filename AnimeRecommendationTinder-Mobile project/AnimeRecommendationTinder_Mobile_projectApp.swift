//
// AnimeRecommendationTinder_Mobile_projectApp.swift
// AnimeRecommendationTinder-Mobile project
//
// The entry point of the entire app.
// @main tells Swift this is where the app starts.
// WindowGroup displays ContentView as the root screen.
// No SwiftData or external dependencies needed here —
// all data handling is done through our Services and Storage layers.
//

import SwiftUI

@main
struct AnimeRecommendationTinder_Mobile_projectApp: App {
    var body: some Scene {
        WindowGroup {
            // ContentView is the root of our app.
            // It will eventually hold our TabView and
            // all navigation for the whole app.
            ContentView()
        }
    }
}
