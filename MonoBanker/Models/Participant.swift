//
//  Participant.swift
//  MonoBanker
//
//  Abstraction over a drag source / drop target: either a Player or the Bank.
//

import Foundation

enum Participant: Hashable, Codable {
    case player(UUID)
    case bank
    case all

    var isBank: Bool {
        if case .bank = self { return true }
        return false
    }

    var isAll: Bool {
        if case .all = self { return true }
        return false
    }

    /// True for participants without a tracked balance (Bank, All).
    var hasNoBalance: Bool { isBank || isAll }
}
