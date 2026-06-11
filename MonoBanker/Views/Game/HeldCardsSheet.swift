//
//  HeldCardsSheet.swift
//  MonoBanker
//
//  Lists every card currently in any deck's held pile, grouped by deck.
//  Each row has a Return button that bounces the card back to the
//  deck's discard pool (it'll reshuffle in next cycle).
//

import SwiftUI

struct HeldCardsSheet: View {
    @Environment(AppSettings.self) private var settings
    let decks: [CardDeck]
    /// Called when the user taps Return on a card. The closure is
    /// responsible for actually mutating the store; this view stays
    /// purely presentational.
    let onReturn: (_ deckID: UUID, _ cardText: String) -> Void
    let onDismiss: () -> Void

    private var decksWithHeld: [CardDeck] {
        decks.filter { !$0.heldPile.isEmpty }
    }

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if decksWithHeld.isEmpty {
                    Spacer()
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "tray")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(.textSecondary)
                        Text("No held cards")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxl) {
                            ForEach(decksWithHeld) { deck in
                                deckSection(deck)
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                        .padding(.vertical, DesignSystem.Spacing.md)
                        .padding(.bottom, DesignSystem.Spacing.xxxl)
                    }
                }
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack {
            Button {
                HapticManager.shared.lightImpact()
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.brandPrimary)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }

            Spacer()

            Text("Held Cards")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textPrimary)

            Spacer()

            Spacer().frame(width: 44)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, DesignSystem.Spacing.md)
    }

    private func deckSection(_ deck: CardDeck) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text(deck.name.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .kerning(1.2)
                Spacer()
                Text("\(deck.heldPile.count) HELD")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .kerning(1.2)
            }

            ForEach(Array(deck.heldPile.enumerated()), id: \.offset) { _, text in
                Card {
                    HStack(alignment: .center, spacing: DesignSystem.Spacing.md) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.brandPrimary)
                            .frame(width: 28, height: 28)
                            .background(Circle().fill(Color.brandPrimary.opacity(0.18)))

                        Text(settings.displayCurrency.rewritingSymbols(in: text))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button {
                            HapticManager.shared.success()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                onReturn(deck.id, text)
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.uturn.left")
                                    .font(.system(size: 11, weight: .semibold))
                                Text("RETURN")
                                    .font(.system(size: 10, weight: .semibold))
                                    .kerning(1.2)
                            }
                            .foregroundColor(.brandPrimary)
                            .padding(.horizontal, DesignSystem.Spacing.sm)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.brandPrimary.opacity(0.15))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.brandPrimary.opacity(0.4), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
