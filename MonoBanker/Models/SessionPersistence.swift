//
//  SessionPersistence.swift
//  MonoBanker
//
//  Saves the active GameSession to UserDefaults so it survives app kill / relaunch.
//

import Foundation

enum SessionPersistence {
    /// Bump this key when changing the snapshot format incompatibly.
    private static let key = "monobanker.session.v1"

    /// Save `session` to disk. Passing nil clears any saved session.
    static func save(_ session: GameSession?) {
        let defaults = UserDefaults.standard
        guard let session, !session.players.isEmpty else {
            defaults.removeObject(forKey: key)
            return
        }
        do {
            let data = try JSONEncoder().encode(session.snapshot)
            defaults.set(data, forKey: key)
        } catch {
            // Best-effort persistence; failing to save shouldn't crash gameplay.
        }
    }

    /// Load a previously saved session, or `nil` if none / corrupt.
    static func load() -> GameSession? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        do {
            let snapshot = try JSONDecoder().decode(GameSessionSnapshot.self, from: data)
            return GameSession(snapshot: snapshot)
        } catch {
            // Discard corrupt data.
            UserDefaults.standard.removeObject(forKey: key)
            return nil
        }
    }

    /// Explicit clear (called on End Game).
    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
