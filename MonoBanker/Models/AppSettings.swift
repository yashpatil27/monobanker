//
//  AppSettings.swift
//  MonoBanker
//
//  Persistent user preferences: default player roster, default starting balance,
//  haptics enabled, etc. Saved to UserDefaults.
//

import Foundation
import Observation

/// A saved default player — used to pre-populate new games.
struct DefaultPlayer: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var color: PlayerColor

    init(id: UUID = UUID(), name: String, color: PlayerColor) {
        self.id = id
        self.name = name
        self.color = color
    }
}

@Observable
final class AppSettings {
    /// Hard cap on default players (matches PlayerColor.allCases.count = 8).
    static let maxDefaultPlayers = 8

    var defaultPlayers: [DefaultPlayer] {
        didSet { persist() }
    }
    var defaultStartingBalance: Int {
        didSet { persist() }
    }
    var hapticsEnabled: Bool {
        didSet {
            HapticManager.shared.isEnabled = hapticsEnabled
            persist()
        }
    }

    init() {
        let snapshot = SettingsPersistence.load()
        self.defaultPlayers = snapshot?.defaultPlayers ?? []
        self.defaultStartingBalance = snapshot?.defaultStartingBalance ?? 1500
        self.hapticsEnabled = snapshot?.hapticsEnabled ?? true
        // Keep HapticManager in sync with persisted setting at launch.
        HapticManager.shared.isEnabled = self.hapticsEnabled
    }

    var usedDefaultColors: Set<PlayerColor> {
        Set(defaultPlayers.map(\.color))
    }

    /// Whether the user can add another default player.
    var canAddDefaultPlayer: Bool {
        defaultPlayers.count < AppSettings.maxDefaultPlayers
    }

    /// Returns the first available color, or `nil` if all are used.
    func nextAvailableColor() -> PlayerColor? {
        PlayerColor.allCases.first { !usedDefaultColors.contains($0) }
    }

    @discardableResult
    func addDefaultPlayer(name: String, color: PlayerColor) -> DefaultPlayer? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty,
              !usedDefaultColors.contains(color),
              canAddDefaultPlayer else { return nil }
        let new = DefaultPlayer(name: trimmed, color: color)
        defaultPlayers.append(new)
        return new
    }

    func removeDefaultPlayer(id: UUID) {
        defaultPlayers.removeAll { $0.id == id }
    }

    private func persist() {
        SettingsPersistence.save(
            AppSettingsSnapshot(
                defaultPlayers: defaultPlayers,
                defaultStartingBalance: defaultStartingBalance,
                hapticsEnabled: hapticsEnabled
            )
        )
    }
}

// MARK: - Persistence

struct AppSettingsSnapshot: Codable {
    let defaultPlayers: [DefaultPlayer]
    let defaultStartingBalance: Int
    let hapticsEnabled: Bool
}

enum SettingsPersistence {
    private static let key = "monobanker.settings.v1"

    static func save(_ snapshot: AppSettingsSnapshot) {
        do {
            let data = try JSONEncoder().encode(snapshot)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            // Best-effort.
        }
    }

    static func load() -> AppSettingsSnapshot? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(AppSettingsSnapshot.self, from: data)
    }
}
