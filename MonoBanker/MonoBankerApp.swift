//
//  MonoBankerApp.swift
//  MonoBanker
//

import SwiftUI

@main
struct MonoBankerApp: App {
    @State private var appState = AppState()
    @State private var appSettings = AppSettings()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(appSettings)
                .preferredColorScheme(.dark)
                .tint(.brandPrimary)
        }
    }
}
