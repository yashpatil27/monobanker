//
//  Player.swift
//  MonoBanker
//

import Foundation

struct Player: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var color: PlayerColor
    var balance: Int

    init(id: UUID = UUID(), name: String, color: PlayerColor, balance: Int) {
        self.id = id
        self.name = name
        self.color = color
        self.balance = balance
    }
}
