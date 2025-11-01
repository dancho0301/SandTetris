//
//  sandtetrisApp.swift
//  sandtetris
//
//  Created by dancho on 2025/10/26.
//

import SwiftUI
import SwiftData
import GoogleMobileAds

@main
struct sandtetrisApp: App {
    @StateObject private var adMobManager = AdMobManager.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            HighScore.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        // AdMob SDKを初期化
        AdMobManager.shared.initializeAdMob()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(adMobManager)
        }
        .modelContainer(sharedModelContainer)
    }
}
