//
//  DiceCard.swift
//  MonoBanker
//

import SwiftUI

struct DiceCard: View {
    let left: Int
    let right: Int
    let onRoll: () -> Void

    var body: some View {
        Button(action: onRoll) {
            HStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "die.face.\(left)")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .symbolEffect(.bounce, value: left)
                Image(systemName: "die.face.\(right)")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .symbolEffect(.bounce, value: right)
            }
            .padding(.horizontal, DesignSystem.Spacing.md)
            .padding(.vertical, DesignSystem.Spacing.sm)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(Color.gray.opacity(DesignSystem.Opacity.subtle))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .stroke(Color.gray.opacity(DesignSystem.Opacity.medium), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Dice. Tap to roll. Currently showing \(left) and \(right).")
    }
}

#Preview {
    DiceCard(left: 4, right: 6, onRoll: {})
        .frame(width: 160, height: 64)
        .padding()
        .background(Color.black)
}
