//
//  AnimeRecommendationTinder_Mobile_projectApp.swift
//  AnimeRecommendationTinder-Mobile project
//
//  Created by EJ Rose on 04/04/2026.
//

import SwiftUI
import SwiftData

@main
struct AnimeRecommendationTinder_Mobile_projectApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
