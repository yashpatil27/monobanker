//
//  AppState.swift
//  MonoBanker
//

import Foundation
import Observation

@Observable
final class AppState {
    var activeSession: GameSession?

    init(activeSession: GameSession? = nil) {
        // Prefer restoring a persisted session over the explicit argument.
        self.activeSession = activeSession ?? SessionPersistence.load()
        installPersistHook()
    }

    var hasActiveSession: Bool { activeSession != nil }

    func endGame() {
        activeSession = nil
        SessionPersistence.clear()
    }

    func startGame(players: [Player], startingBalance: Int) {
        activeSession = GameSession(players: players, startingBalance: startingBalance)
        installPersistHook()
        SessionPersistence.save(activeSession)
    }

    /// Wires the current session's mutation hook to persistence.
    private func installPersistHook() {
        activeSession?.didMutate = { [weak self] in
            SessionPersistence.save(self?.activeSession)
        }
    }
}
