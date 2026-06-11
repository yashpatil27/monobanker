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
    /// shuffled pile. When the pile is empty, refills it from
    /// `cards.shuffled()` minus any cards currently in `heldPile`, then
    /// draws. If the drawn card is flagged ownable it lands in
    /// `heldPile` (and remains there until the player returns it).
    ///
    /// Returns nil only when the deck has no cards at all.
    func draw(fromDeckID deckID: UUID) -> String? {
        guard let index = decks.firstIndex(where: { $0.id == deckID }) else { return nil }
        var deck = decks[index]
        guard !deck.cards.isEmpty else { return nil }

        // Drop any pile entries the user has since deleted from the deck.
        let validCards = Set(deck.cards)
        deck.drawPile.removeAll { !validCards.contains($0) }
        deck.heldPile.removeAll { !validCards.contains($0) }
        deck.ownableCards = deck.ownableCards.intersection(validCards)

        // Refill with a fresh shuffle whenever the pile is exhausted.
        // Held cards are subtracted so they don't reappear until returned.
        if deck.drawPile.isEmpty {
            var available = deck.cards
            for held in deck.heldPile {
                if let idx = available.firstIndex(of: held) {
                    available.remove(at: idx)
                }
            }
            // If literally every card is held, fall back to all cards so
            // the player can still draw something. Should be vanishingly rare.
            if available.isEmpty {
                available = deck.cards
            }
            deck.drawPile = available.shuffled()
        }

        let drawn = deck.drawPile.removeLast()

        // Ownable cards are stashed in the held pile instead of being discarded.
        if deck.ownableCards.contains(drawn) {
            deck.heldPile.append(drawn)
        }

        decks[index] = deck  // triggers didSet → persist
        return drawn
    }

    /// Returns a single held card to the discard. The card stays out of
    /// the current draw cycle but will be reshuffled in next time the
    /// deck is refilled. No-op if the card isn't currently held.
    func returnHeldCard(_ text: String, fromDeckID deckID: UUID) {
        guard let index = decks.firstIndex(where: { $0.id == deckID }) else { return }
        var deck = decks[index]
        guard let heldIdx = deck.heldPile.firstIndex(of: text) else { return }
        deck.heldPile.remove(at: heldIdx)
        decks[index] = deck
    }

    /// Total number of cards currently held across all decks.
    var totalHeldCount: Int {
        decks.reduce(0) { $0 + $1.heldPile.count }
    }

    /// Clears every deck's drawPile and heldPile while preserving the
    /// user's authored cards, deck names, and ownable flags. Use this
    /// when the game restarts or ends so held cards don't carry into a
    /// fresh session.
    func resetAllPiles() {
        for index in decks.indices {
            decks[index].drawPile.removeAll()
            decks[index].heldPile.removeAll()
        }
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
