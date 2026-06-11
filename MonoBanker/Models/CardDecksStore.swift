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

    // ============================================================
    // WARNING — THIRD-PARTY IP CONTENT BELOW
    //
    // The two default decks are currently pre-populated with the
    // verbatim Monopoly UK "Chance" and "Community Chest" cards. The
    // text, deck names, and board-location references (Mayfair,
    // Trafalgar Square, Pall Mall, Kings Cross Station, etc.) are
    // Hasbro trademarks/copyrights and SHOULD NOT BE SHIPPED to the
    // App Store as-is. Replace with original/generic content before
    // submitting any build for review.
    // ============================================================
    static func defaultDecks() -> [CardDeck] {
        let chance: [String] = [
            "Advance to Go (Collect £200)",
            "Advance to Trafalgar Square. If you pass Go, collect £200",
            "Advance to Mayfair",
            "Advance to Pall Mall. If you pass Go, collect £200",
            "Advance to the nearest Station. If unowned, you may buy it from the Bank. If owned, pay owner twice the rental to which they are otherwise entitled.",
            "Advance to the nearest Station. If unowned, you may buy it from the Bank. If owned, pay owner twice the rental to which they are otherwise entitled.",
            "Advance token to nearest Utility. If unowned, you may buy it from the Bank. If owned, throw dice and pay owner a total ten times amount thrown.",
            "Bank pays you dividend of £50",
            "Get Out of Jail Free",
            "Go Back 3 Spaces",
            "Go to Jail. Go directly to Jail, do not pass Go, do not collect £200",
            "Make general repairs on all your property. For each house pay £25. For each hotel pay £100",
            "Speeding fine £15",
            "Take a trip to Kings Cross Station. If you pass Go, collect £200",
            "You have been elected Chairman of the Board. Pay each player £50",
            "Your building loan matures. Collect £150",
        ]

        let communityChest: [String] = [
            "Advance to Go (Collect £200)",
            "Bank error in your favour. Collect £200",
            "Doctor’s fee. Pay £50",
            "From sale of stock you get £50",
            "Get Out of Jail Free",
            "Go to Jail. Go directly to jail, do not pass Go, do not collect £200",
            "Holiday fund matures. Receive £100",
            "Income tax refund. Collect £20",
            "It is your birthday. Collect £10 from every player",
            "Life insurance matures. Collect £100",
            "Pay hospital fees of £100",
            "Pay school fees of £50",
            "Receive £25 consultancy fee",
            "You are assessed for street repairs. £40 per house. £115 per hotel",
            "You have won second prize in a beauty contest. Collect £10",
            "You inherit £100",
        ]

        return [
            CardDeck(name: "Chance", cards: chance),
            CardDeck(name: "Community Chest", cards: communityChest),
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
