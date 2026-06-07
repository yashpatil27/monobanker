//
//  RootView.swift
//  MonoBanker
//

import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @State private var isPlaying = false
    @State private var showingSetup = false

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            if isPlaying, let session = appState.activeSession {
                GameView(session: session, onEndGame: {
                    appState.endGame()
                    isPlaying = false
                })
                .transition(.opacity)
            } else {
                LaunchView(
                    onNewGame: { showingSetup = true },
                    onContinue: { isPlaying = true }
                )
                .transition(.opacity)
            }
        }
        .fullScreenCover(isPresented: $showingSetup) {
            SetupView(onStart: { players, startingBalance in
                appState.startGame(players: players, startingBalance: startingBalance)
                showingSetup = false
                isPlaying = true
            })
        }
        .animation(.easeInOut(duration: 0.25), value: isPlaying)
        .onAppear {
            // Auto-resume into the game if a session was restored from disk.
            if appState.activeSession != nil && !isPlaying {
                isPlaying = true
            }
        }
    }
}
