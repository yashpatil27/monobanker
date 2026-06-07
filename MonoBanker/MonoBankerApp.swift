//
//  MonoBankerApp.swift
//  MonoBanker
//

import SwiftUI

@main
struct MonoBankerApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .preferredColorScheme(.dark)
                .tint(.brandPrimary)
        }
    }
}
