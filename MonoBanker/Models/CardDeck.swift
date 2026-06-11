//
//  CardDeck.swift
//  MonoBanker
//
//  A user-editable deck of text cards. The app ships with empty decks
//  and a generic name; users author and rename them locally. Card
//  content is stored only on-device — no shared/preset deck content is
//  bundled with the app, which keeps the feature out of third-party IP
//  territory and makes the random-draw card cycler a generic utility.
//

import Foundation

struct CardDeck: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var cards: [String]
    /// Remaining shuffled cards for the current draw-without-replacement
    /// cycle. When empty, the next draw refills it from
    /// `cards.shuffled()` minus anything in `heldPile`, mirroring the
    /// physical "draw, set aside, reshuffle when exhausted" behavior.
    var drawPile: [String]
    /// Cards drawn but currently held by a player (kept out of
    /// circulation until returned via the in-game Held Cards button).
    /// Only cards whose text is in `ownableCards` ever land here.
    var heldPile: [String]
    /// Card texts flagged as ownable. When a draw produces a card whose
    /// text is in this set, the card lands in `heldPile` instead of
    /// being immediately discarded.
    var ownableCards: Set<String>

    init(
        id: UUID = UUID(),
        name: String,
        cards: [String] = [],
        drawPile: [String] = [],
        heldPile: [String] = [],
        ownableCards: Set<String> = []
    ) {
        self.id = id
        self.name = name
        self.cards = cards
        self.drawPile = drawPile
        self.heldPile = heldPile
        self.ownableCards = ownableCards
    }

    var isEmpty: Bool { cards.isEmpty }

    func isOwnable(_ text: String) -> Bool { ownableCards.contains(text) }

    // MARK: - Codable (back-compat)

    enum CodingKeys: String, CodingKey {
        case id, name, cards, drawPile, heldPile, ownableCards
    }

    /// Custom decoder so older snapshots without `drawPile`, `heldPile`,
    /// or `ownableCards` still load — missing fields decode as empty.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.cards = try container.decode([String].self, forKey: .cards)
        self.drawPile = try container.decodeIfPresent([String].self, forKey: .drawPile) ?? []
        self.heldPile = try container.decodeIfPresent([String].self, forKey: .heldPile) ?? []
        self.ownableCards = try container.decodeIfPresent(Set<String>.self, forKey: .ownableCards) ?? []
    }
}
