//
//  Currency.swift
//  MonoBanker
//
//  Display-only currency symbol used in place of "$" throughout the UI.
//  Selection is persisted via AppSettings.displayCurrency. Note: amounts
//  are not converted — only the symbol changes.
//

import Foundation

enum Currency: String, Codable, CaseIterable, Identifiable, Hashable {
    case usd
    case eur
    case gbp
    case jpy
    case krw
    case inr
    case btc
    /// Korean Won rendered upside down — visual gag option.
    case invertedWon

    var id: String { rawValue }

    /// The literal character drawn for this currency. For `invertedWon`
    /// the same Won glyph is used and rendered with a 180° rotation by
    /// the `CurrencySymbol` view.
    var symbol: String {
        switch self {
        case .usd:          return "$"
        case .eur:          return "€"
        case .gbp:          return "£"
        case .jpy:          return "¥"
        case .krw:          return "₩"
        case .inr:          return "₹"
        case .btc:          return "₿"
        case .invertedWon:  return "₩"
        }
    }

    /// Whether the symbol should be rendered with a 180° rotation.
    var isRotated: Bool { self == .invertedWon }

    /// Common currency glyphs we recognise inside free-form text (e.g.
    /// imported Chance/Community Chest cards) and swap for the user's
    /// selected display currency.
    static let knownSymbols: Set<Character> = ["$", "€", "£", "¥", "₩", "₹", "₿"]

    /// Returns `text` with every recognised currency glyph swapped for
    /// this currency's `symbol`. Note: the inverted-Won variant only
    /// rotates inside the dedicated `CurrencySymbol` view — inside long
    /// card body text it appears as a normal Won glyph, since per-glyph
    /// rotation isn't viable in a multiline `Text`.
    func rewritingSymbols(in text: String) -> String {
        guard text.contains(where: Currency.knownSymbols.contains) else { return text }
        var result = ""
        result.reserveCapacity(text.count)
        for char in text {
            result.append(Currency.knownSymbols.contains(char) ? symbol : String(char))
        }
        return result
    }

    /// Human-readable label used in pickers and trailing info rows.
    var displayName: String {
        switch self {
        case .usd:          return "US Dollar"
        case .eur:          return "Euro"
        case .gbp:          return "British Pound"
        case .jpy:          return "Japanese Yen"
        case .krw:          return "Korean Won"
        case .inr:          return "Indian Rupee"
        case .btc:          return "Bitcoin"
        case .invertedWon:  return "Inverted Won"
        }
    }
}
