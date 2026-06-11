//
//  CardDrawSheet.swift
//  MonoBanker
//
//  Full-screen card reveal shown after the user taps a deck button in
//  the game. Pure presentation — no state is mutated here; the deck and
//  card text are passed in by GameView.
//

import SwiftUI

struct CardDrawSheet: View {
    @Environment(AppSettings.self) private var settings
    let deckName: String
    let cardText: String
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                Spacer(minLength: 0)

                cardView
                    .padding(.horizontal, DesignSystem.Spacing.xl)

                Spacer(minLength: 0)

                Button {
                    HapticManager.shared.lightImpact()
                    onDismiss()
                } label: {
                    Text("Done")
                }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.bottom, DesignSystem.Spacing.xl)
            }
        }
    }

    private var header: some View {
        HStack {
            Text(deckName.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.textSecondary)
                .kerning(1.6)
                .lineLimit(1)
            Spacer()
            Button {
                HapticManager.shared.lightImpact()
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Color.gray.opacity(0.15)))
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.xl)
        .padding(.top, DesignSystem.Spacing.lg)
    }

    private var cardView: some View {
        Text(settings.displayCurrency.rewritingSymbols(in: cardText))
            .font(.system(size: 22, weight: .medium, design: .rounded))
            .foregroundColor(.textPrimary)
            .multilineTextAlignment(.center)
            .padding(DesignSystem.Spacing.xxxl)
            .frame(maxWidth: .infinity, minHeight: 220)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(Color.gray.opacity(DesignSystem.Opacity.subtle))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .stroke(Color.brandPrimary.opacity(0.5), lineWidth: 1.5)
                    )
            )
    }
}
