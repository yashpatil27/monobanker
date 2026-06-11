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
    /// cycle. When empty, the next draw refills it from `cards.shuffled()`,
    /// mirroring the physical "draw a card, set it aside, reshuffle when
    /// the deck is exhausted" behavior.
    var drawPile: [String]

    init(id: UUID = UUID(), name: String, cards: [String] = [], drawPile: [String] = []) {
        self.id = id
        self.name = name
        self.cards = cards
        self.drawPile = drawPile
    }

    var isEmpty: Bool { cards.isEmpty }

    // MARK: - Codable (back-compat)

    enum CodingKeys: String, CodingKey {
        case id, name, cards, drawPile
    }

    /// Custom decoder so snapshots saved before `drawPile` existed still
    /// load — missing field decodes as an empty pile (next draw shuffles).
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.cards = try container.decode([String].self, forKey: .cards)
        self.drawPile = try container.decodeIfPresent([String].self, forKey: .drawPile) ?? []
    }
}
