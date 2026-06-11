//
//  CardDecksStore.swift
//  MonoBanker
//
//  Holds the user's two editable card decks and provides random-draw
//  access. Persists changes to UserDefaults under
//  `monobanker.carddecks.v1`.
//

import Foundation
import Observation

@Observable
final class CardDecksStore {
    var decks: [CardDeck] {
        didSet { persist() }
    }

    init() {
        let snapshot = CardDecksPersistence.load()
        self.decks = snapshot?.decks ?? CardDecksStore.defaultDecks()
    }

    /// Two empty, user-renameable decks. The app bundle ships no card
    /// content — users populate decks by editing manually or by importing
    /// a JSON file from the Files app, iCloud Drive, etc.
    static func defaultDecks() -> [CardDeck] {
        [
            CardDeck(name: "Deck 1"),
            CardDeck(name: "Deck 2"),
        ]
    }

    /// Draws one card without replacement from the given deck's current
    /// shuffled pile. When the pile is empty, refills it with a fresh
    /// shuffle of all of the deck's cards before drawing — same idea as
    /// shuffling a physical deck once it's been fully cycled through.
    ///
    /// Returns nil only when the deck has no cards at all.
    func draw(fromDeckID deckID: UUID) -> String? {
        guard let index = decks.firstIndex(where: { $0.id == deckID }) else { return nil }
        var deck = decks[index]
        guard !deck.cards.isEmpty else { return nil }

        // Drop any pile entries the user has since deleted from the deck.
        let validCards = Set(deck.cards)
        deck.drawPile.removeAll { !validCards.contains($0) }

        // Refill with a fresh shuffle whenever the pile is exhausted.
        if deck.drawPile.isEmpty {
            deck.drawPile = deck.cards.shuffled()
        }

        let drawn = deck.drawPile.removeLast()
        decks[index] = deck  // triggers didSet → persist
        return drawn
    }

    private func persist() {
        CardDecksPersistence.save(CardDecksSnapshot(decks: decks))
    }
}

// MARK: - Persistence

struct CardDecksSnapshot: Codable {
    let decks: [CardDeck]
}

enum CardDecksPersistence {
    private static let key = "monobanker.carddecks.v1"

    static func save(_ snapshot: CardDecksSnapshot) {
        do {
            let data = try JSONEncoder().encode(snapshot)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            // Best-effort. Failing here is non-fatal.
        }
    }

    static func load() -> CardDecksSnapshot? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(CardDecksSnapshot.self, from: data)
    }
}
