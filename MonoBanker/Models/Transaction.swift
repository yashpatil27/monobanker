//
//  Transaction.swift
//  MonoBanker
//

import Foundation

struct Transaction: Identifiable, Hashable, Codable {
    let id: UUID
    let timestamp: Date
    let from: Participant
    let to: Participant
    let amount: Int

    init(id: UUID = UUID(),
         timestamp: Date = Date(),
         from: Participant,
         to: Participant,
         amount: Int) {
        self.id = id
        self.timestamp = timestamp
        self.from = from
        self.to = to
        self.amount = amount
    }
}
