//
//  CardDecksView.swift
//  MonoBanker
//
//  Sub-page under Game Preferences for editing the two card decks. Lets
//  the user rename each deck and add/remove cards. All edits flow
//  directly into CardDecksStore via SwiftUI bindings.
//

import SwiftUI

struct CardDecksView: View {
    @Environment(CardDecksStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var store = store

        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxl) {
                        Text("Add your own cards to each deck. Tap a deck button in the game to draw one at random. Decks and cards stay on your device.")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)

                        ForEach($store.decks) { $deck in
                            DeckEditorSection(deck: $deck)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.xxxl)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack {
            Button {
                HapticManager.shared.lightImpact()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.brandPrimary)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }

            Spacer()

            Text("Card Decks")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textPrimary)

            Spacer()

            Spacer().frame(width: 44)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, 2)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}

// MARK: - Deck editor

private struct DeckEditorSection: View {
    @Binding var deck: CardDeck
    @State private var newCard: String = ""
    @FocusState private var newCardFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Section header with card count.
            HStack {
                Text("DECK")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .kerning(1.2)
                Spacer()
                Text("\(deck.cards.count) CARDS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .kerning(1.2)
            }

            // Editable deck name.
            Card {
                HStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "rectangle.stack")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .frame(width: 24)
                    TextField("Deck name", text: $deck.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .tint(.brandPrimary)
                        .submitLabel(.done)
                }
            }

            // Existing cards.
            ForEach(Array(deck.cards.enumerated()), id: \.offset) { index, text in
                Card {
                    HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                        Text(text)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                        Button {
                            HapticManager.shared.lightImpact()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                _ = deck.cards.remove(at: index)
                            }
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.error)
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(Color.error.opacity(0.15)))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Add a new card.
            Card {
                HStack(alignment: .center, spacing: DesignSystem.Spacing.md) {
                    TextField("New card text", text: $newCard, axis: .vertical)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.textPrimary)
                        .tint(.brandPrimary)
                        .focused($newCardFocused)
                        .lineLimit(1...4)
                        .submitLabel(.done)
                        .onSubmit(addCard)
                    Button(action: addCard) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(canAdd ? .black : .textSecondary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle().fill(canAdd ? Color.brandPrimary : Color.gray.opacity(0.2))
                            )
                    }
                    .disabled(!canAdd)
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var canAdd: Bool {
        !newCard.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func addCard() {
        let trimmed = newCard.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        HapticManager.shared.lightImpact()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            deck.cards.append(trimmed)
            newCard = ""
        }
        newCardFocused = true
    }
}
