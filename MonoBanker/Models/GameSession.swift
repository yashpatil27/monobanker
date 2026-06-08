//
//  GameSession.swift
//  MonoBanker
//
//  In-memory game state. Bank is treated as having unlimited funds (no stored balance).
//

import Foundation
import Observation

@Observable
final class GameSession {
    var players: [Player]
    var transactions: [Transaction]
    var startingBalance: Int
    let startedAt: Date

    /// Called after every successful state mutation (pay/undo). Used to drive persistence.
    /// The closure is held strongly; callers should weak-capture themselves if needed.
    var didMutate: (() -> Void)?

    init(players: [Player], startingBalance: Int, startedAt: Date = Date()) {
        self.players = players
        self.startingBalance = startingBalance
        self.transactions = []
        self.startedAt = startedAt
    }

    /// Restores a session from a persisted snapshot.
    convenience init(snapshot: GameSessionSnapshot) {
        self.init(
            players: snapshot.players,
            startingBalance: snapshot.startingBalance,
            startedAt: snapshot.startedAt
        )
        self.transactions = snapshot.transactions
    }

    /// A serializable snapshot of the current session.
    var snapshot: GameSessionSnapshot {
        GameSessionSnapshot(
            players: players,
            transactions: transactions,
            startingBalance: startingBalance,
            startedAt: startedAt
        )
    }

    // MARK: - Lookup

    func player(for id: UUID) -> Player? {
        players.first(where: { $0.id == id })
    }

    /// Display name for any Participant.
    func name(for participant: Participant) -> String {
        switch participant {
        case .bank: return "Bank"
        case .all: return "All"
        case .player(let id): return player(for: id)?.name ?? "?"
        }
    }

    /// Returns the balance for a Participant. Bank and All return nil (no tracked balance).
    func balance(of participant: Participant) -> Int? {
        switch participant {
        case .bank, .all: return nil
        case .player(let id): return player(for: id)?.balance
        }
    }

    /// For an `.all` transaction, the number of "others" relative to the non-All side.
    /// Returns 0 when the opposite side is not a Player.
    func othersCount(opposite participant: Participant) -> Int {
        if case .player(let id) = participant {
            return players.filter { $0.id != id }.count
        }
        return 0
    }

    /// Quick-tap presets shown above the numpad on the transaction overlay.
    ///
    /// Rules:
    /// - Bank involved (either side): fixed `[50, 100, 150, 200]`.
    /// - All involved (either side): fixed `[10, 50]`.
    /// - Player → Player: the most recent 4 unique amounts the recipient has been
    ///   directly paid by another player AND has received that exact amount **at
    ///   least twice** (so one-off trades don't pollute the suggestions). Padded
    ///   with `[10, 20, 30, 40]` when fewer.
    func suggestedAmounts(payer: Participant, recipient: Participant) -> [Int] {
        if payer.isBank || recipient.isBank { return [50, 100, 150, 200] }
        if payer.isAll || recipient.isAll  { return [10, 50] }

        guard case .player(let recipientID) = recipient else { return [] }

        // Predicate: is `tx` a direct player-to-player payment received by `recipientID`?
        func receivedHere(_ tx: Transaction) -> Bool {
            guard case .player(let payerID) = tx.from, payerID != recipientID,
                  case .player(let toID) = tx.to, toID == recipientID else { return false }
            return true
        }

        // Pass 1: count how often each amount has been paid to this recipient.
        var occurrences: [Int: Int] = [:]
        for tx in transactions where receivedHere(tx) {
            occurrences[tx.amount, default: 0] += 1
        }
        // Amounts that have shown up at least twice — these are the only candidates.
        let eligible = Set(occurrences.filter { $0.value >= 2 }.keys)

        // Pass 2: walk newest → oldest, pick the 4 most recent unique eligible amounts.
        var recent: [Int] = []
        var seen: Set<Int> = []
        for tx in transactions.reversed() where receivedHere(tx) {
            guard eligible.contains(tx.amount), !seen.contains(tx.amount) else { continue }
            recent.append(tx.amount)
            seen.insert(tx.amount)
            if recent.count >= 4 { break }
        }

        // Pad with [10, 20, 30, 40] in order, skipping any already present.
        for fallback in [10, 20, 30, 40] {
            if recent.count >= 4 { break }
            if !seen.contains(fallback) {
                recent.append(fallback)
                seen.insert(fallback)
            }
        }

        // Display the chips in ascending order so the row reads small → large.
        return recent.sorted()
    }

    /// The signed change to this player's balance from the most recent transaction
    /// that involved them. `nil` if they haven't participated in any transaction yet.
    func lastDelta(for playerID: UUID) -> Int? {
        for tx in transactions.reversed() {
            if let delta = delta(for: playerID, in: tx) {
                return delta
            }
        }
        return nil
    }

    /// The signed change a single transaction applies to a specific player. `nil` if the
    /// transaction did not affect them.
    private func delta(for playerID: UUID, in tx: Transaction) -> Int? {
        let me = Participant.player(playerID)

        // Direct payer or recipient.
        if tx.from == me { return -tx.amount }
        if tx.to   == me { return  tx.amount }

        // Player → All: every "other" gets +perPlayer.
        if tx.to.isAll, case .player = tx.from {
            let count = othersCount(opposite: tx.from)
            if count > 0 { return tx.amount / count }
        }

        // All → Player: every "other" pays –perPlayer.
        if tx.from.isAll, case .player = tx.to {
            let count = othersCount(opposite: tx.to)
            if count > 0 { return -(tx.amount / count) }
        }

        return nil
    }

    // MARK: - Transactions

    /// Whether a transaction is valid.
    /// `totalAmount` is the total money moving in the transaction:
    /// - Direct (Player ↔ Player, Player ↔ Bank): the amount paid.
    /// - Player → All: total = perPlayer × othersCount; must divide evenly; payer.balance >= total.
    /// - All → Player: total = perPlayer × othersCount; must divide evenly; every "other" has balance >= perPlayer.
    /// Bank and All cannot interact with each other. All cannot interact with itself.
    func canPay(from payer: Participant, to recipient: Participant, totalAmount: Int) -> Bool {
        guard totalAmount > 0, payer != recipient else { return false }
        // Bank ↔ All is forbidden.
        if (payer.isBank && recipient.isAll) || (payer.isAll && recipient.isBank) {
            return false
        }
        // All ↔ All is meaningless.
        if payer.isAll && recipient.isAll { return false }

        // Player → All
        if case .player(let payerID) = payer, recipient.isAll {
            guard let p = player(for: payerID) else { return false }
            let count = othersCount(opposite: payer)
            guard count > 0, totalAmount % count == 0 else { return false }
            return p.balance >= totalAmount
        }
        // All → Player
        if payer.isAll, case .player(let recID) = recipient {
            let count = othersCount(opposite: recipient)
            guard count > 0, totalAmount % count == 0 else { return false }
            let perPlayer = totalAmount / count
            return players.filter { $0.id != recID }.allSatisfy { $0.balance >= perPlayer }
        }
        // Direct
        if case .player(let payerID) = payer {
            guard let p = player(for: payerID) else { return false }
            return p.balance >= totalAmount
        }
        return true // Bank as payer is always valid for direct transactions.
    }

    /// Apply a transaction. `totalAmount` semantics match `canPay`.
    /// Returns the recorded `Transaction` on success (its `amount` field stores the total).
    @discardableResult
    func pay(from payer: Participant, to recipient: Participant, totalAmount: Int) -> Transaction? {
        guard canPay(from: payer, to: recipient, totalAmount: totalAmount) else { return nil }

        // Player → All: debit payer total, credit each "other" perPlayer.
        if case .player(let payerID) = payer, recipient.isAll {
            let count = othersCount(opposite: payer)
            let perPlayer = totalAmount / count
            if let idx = players.firstIndex(where: { $0.id == payerID }) {
                players[idx].balance -= totalAmount
            }
            for i in players.indices where players[i].id != payerID {
                players[i].balance += perPlayer
            }
        }
        // All → Player: credit recipient total, debit each "other" perPlayer.
        else if payer.isAll, case .player(let recID) = recipient {
            let count = othersCount(opposite: recipient)
            let perPlayer = totalAmount / count
            if let idx = players.firstIndex(where: { $0.id == recID }) {
                players[idx].balance += totalAmount
            }
            for i in players.indices where players[i].id != recID {
                players[i].balance -= perPlayer
            }
        }
        // Direct
        else {
            if case .player(let id) = payer,
               let idx = players.firstIndex(where: { $0.id == id }) {
                players[idx].balance -= totalAmount
            }
            if case .player(let id) = recipient,
               let idx = players.firstIndex(where: { $0.id == id }) {
                players[idx].balance += totalAmount
            }
        }

        let tx = Transaction(from: payer, to: recipient, amount: totalAmount)
        transactions.append(tx)
        didMutate?()
        return tx
    }

    // MARK: - Roster / restart

    /// Reset every player's balance to the starting amount and clear transaction history.
    func restart() {
        for i in players.indices {
            players[i].balance = startingBalance
        }
        transactions.removeAll()
        didMutate?()
    }

    /// Append a new player at the starting balance. No-op on empty/whitespace name.
    @discardableResult
    func addPlayer(name: String, color: PlayerColor) -> Player? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }
        let new = Player(name: trimmed, color: color, balance: startingBalance)
        players.append(new)
        didMutate?()
        return new
    }

    /// Remove a player from the game. Historical transactions referencing them are preserved
    /// (their display name will resolve to "?" once they're gone).
    func removePlayer(id: UUID) {
        guard players.contains(where: { $0.id == id }) else { return }
        players.removeAll { $0.id == id }
        didMutate?()
    }

    /// Replace the player list with the same set of players in a new order.
    /// Rejects any input that isn't a permutation of the current roster.
    func reorderPlayers(_ newOrder: [Player]) {
        guard Set(newOrder.map(\.id)) == Set(players.map(\.id)),
              newOrder.count == players.count else { return }
        players = newOrder
        didMutate?()
    }

    // MARK: - Undo

    /// Reverse the most recent transaction. Returns true if one was undone.
    @discardableResult
    func undoLast() -> Bool {
        guard let tx = transactions.popLast() else { return false }

        // Player → All: refund payer total, debit each "other" perPlayer.
        if case .player(let payerID) = tx.from, tx.to.isAll {
            let count = othersCount(opposite: tx.from)
            let perPlayer = count > 0 ? tx.amount / count : 0
            if let idx = players.firstIndex(where: { $0.id == payerID }) {
                players[idx].balance += tx.amount
            }
            for i in players.indices where players[i].id != payerID {
                players[i].balance -= perPlayer
            }
        }
        // All → Player: debit recipient total, refund each "other" perPlayer.
        else if tx.from.isAll, case .player(let recID) = tx.to {
            let count = othersCount(opposite: tx.to)
            let perPlayer = count > 0 ? tx.amount / count : 0
            if let idx = players.firstIndex(where: { $0.id == recID }) {
                players[idx].balance -= tx.amount
            }
            for i in players.indices where players[i].id != recID {
                players[i].balance += perPlayer
            }
        }
        // Direct
        else {
            if case .player(let id) = tx.from,
               let idx = players.firstIndex(where: { $0.id == id }) {
                players[idx].balance += tx.amount
            }
            if case .player(let id) = tx.to,
               let idx = players.firstIndex(where: { $0.id == id }) {
                players[idx].balance -= tx.amount
            }
        }
        didMutate?()
        return true
    }
}

// MARK: - Persistence snapshot

struct GameSessionSnapshot: Codable {
    let players: [Player]
    let transactions: [Transaction]
    let startingBalance: Int
    let startedAt: Date
}
