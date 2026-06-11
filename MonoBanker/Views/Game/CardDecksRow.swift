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
    /// Number of currently held cards summed across every deck.
    /// When > 0, a compact person-icon button with a corner-badge
    /// counter is appended to the row.
    let heldCount: Int
    /// Called when the user taps a deck. The closure receives the deck
    /// itself so the caller can decide between drawing a card and
    /// opening the editor when the deck is empty.
    let onTap: (CardDeck) -> Void
    /// Called when the user taps the held-cards badge button.
    let onHeldTap: () -> Void

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

            if heldCount > 0 {
                Button {
                    HapticManager.shared.lightImpact()
                    onHeldTap()
                } label: {
                    heldButton(count: heldCount)
                }
                .buttonStyle(.plain)
                .transition(.scale(scale: 0.7).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: heldCount > 0)
        .animation(.easeOut(duration: 0.2), value: decks.map(\.remainingCount))
    }

    private func deckButton(_ deck: CardDeck) -> some View {
        let isEmpty = deck.isEmpty
        return VStack(spacing: 4) {
            Text(deck.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(isEmpty ? "EMPTY" : "\(deck.remainingCount) LEFT")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.textSecondary)
                .kerning(1.2)
                .monospacedDigit()
                .contentTransition(.numericText(value: Double(deck.remainingCount)))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.md)
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

    /// Square brand-tinted icon container with a corner badge showing
    /// the current held-cards count. Sits flush against the deck
    /// buttons so it reads as part of the same control row.
    private func heldButton(count: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: "person.fill")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.textPrimary)
                .frame(width: 58, height: 58)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(Color.gray.opacity(DesignSystem.Opacity.subtle))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                .stroke(Color.gray.opacity(DesignSystem.Opacity.medium), lineWidth: 1)
                        )
                )

            Text("\(count)")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.brandPrimary)
                .monospacedDigit()
                .frame(minWidth: 20, minHeight: 20)
                .padding(.horizontal, 4)
                .background(
                    Capsule()
                        .fill(Color.bgPrimary)
                        .overlay(
                            Capsule().stroke(Color.brandPrimary, lineWidth: 1.5)
                        )
                )
                .offset(x: 7, y: -7)
        }
        .accessibilityLabel("\(count) held card\(count == 1 ? "" : "s"). Tap to view.")
    }
}
