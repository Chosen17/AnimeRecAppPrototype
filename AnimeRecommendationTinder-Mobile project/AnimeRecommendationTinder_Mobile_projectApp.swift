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
            // here I are putting the app to dark mode as this is what I put in my prototype/proposal
            // the reason why i put dark mode is because it will make the anime images and display pop (thinking of app like crunchyroll, dark mode looks alot better than light and i think it is the default even on their website.
                .preferredColorScheme(.dark).tint(Color(red: 0.4, green: 0.2, blue: 0.8))
            
            // the purple accents that will be put in will affect the toggles, the buttons, and interactive elements across every screen so i don't need to set it individually ensuring consistency.
            
            
        }
    }
}
