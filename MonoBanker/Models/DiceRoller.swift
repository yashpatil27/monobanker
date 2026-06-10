//
//  DiceRoller.swift
//  MonoBanker
//
//  Centralized source of dice-roll outcomes. Wrapping Swift's
//  `Int.random(in:)` here gives unit tests a single seam to verify the
//  distribution of outcomes, and lets the game and tests share the exact
//  same RNG path.
//

import Foundation

enum DiceRoller {
    /// Rolls a single six-sided die. Each face 1...6 has equal probability,
    /// drawn from `SystemRandomNumberGenerator` via `Int.random(in:)`.
    static func roll() -> Int {
        Int.random(in: 1...6)
    }

    /// Rolls a pair of independent six-sided dice.
    static func rollPair() -> (left: Int, right: Int) {
        (roll(), roll())
    }
}
