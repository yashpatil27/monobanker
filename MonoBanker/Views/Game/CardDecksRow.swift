//
//  CardDecksRow.swift
//  MonoBanker
//
//  Compact two-button row that lives just above the HistoryStrip when
//  the user has enabled `cardDecksEnabled`. Tapping a deck draws a
//  random card from its contents and bubbles the result up to GameView.
//

import SwiftUI

struct CardDecksRow: View {
    let decks: [CardDeck]
    /// Called when the user taps a deck. The closure receives the deck
    /// itself so the caller can decide between drawing a card and
    /// opening the editor when the deck is empty.
    let onTap: (CardDeck) -> Void

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ForEach(decks) { deck in
                Button {
                    HapticManager.shared.lightImpact()
                    onTap(deck)
                } label: {
                    deckButton(deck)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func deckButton(_ deck: CardDeck) -> some View {
        let isEmpty = deck.isEmpty
        return VStack(spacing: 2) {
            Text(deck.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(isEmpty ? "EMPTY" : "TAP TO DRAW")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.textSecondary)
                .kerning(1.2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(Color.gray.opacity(DesignSystem.Opacity.subtle))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .stroke(Color.gray.opacity(DesignSystem.Opacity.medium), lineWidth: 1)
                )
        )
        .opacity(isEmpty ? 0.55 : 1.0)
    }
}
