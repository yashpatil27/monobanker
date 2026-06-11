//
//  MonoBankerApp.swift
//  MonoBanker
//

import SwiftUI

@main
struct MonoBankerApp: App {
    @State private var appState = AppState()
    @State private var appSettings = AppSettings()
    @State private var cardDecksStore = CardDecksStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(appSettings)
                .environment(cardDecksStore)
                .preferredColorScheme(.dark)
                .tint(.brandPrimary)
        }
    }
}
