//
//  DiceCard.swift
//  MonoBanker
//

import SwiftUI

struct DiceCard: View {
    let left: Int
    let right: Int
    /// Monotonic counter incremented on every roll. Drives `.onChange` so the
    /// tumble animation fires even when the rolled value matches the previous one.
    let rollID: Int
    let onRoll: () -> Void
    /// The face currently drawn for each die. Diverges from `left`/`right`
    /// briefly while the dice are tumbling (cycling through random faces).
    @State private var displayLeft: Int = 1
    @State private var displayRight: Int = 1

    /// Accumulated rotation per die. Adding 720° per roll keeps the spin
    /// going in one direction without a snap-back between rolls.
    @State private var rotationLeft: Double = 0
    @State private var rotationRight: Double = 0

    var body: some View {
        Button(action: onRoll) {
            HStack(spacing: DesignSystem.Spacing.md) {
                die(value: displayLeft, rotation: rotationLeft)
                die(value: displayRight, rotation: rotationRight)
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
        .onAppear {
            displayLeft = left
            displayRight = right
        }
        .onChange(of: rollID) {
            roll(toLeft: left, toRight: right)
        }
    }

    private func die(value: Int, rotation: Double) -> some View {
        Image(systemName: "die.face.\(value)")
            .font(.system(size: 48, weight: .medium))
            .foregroundColor(.textPrimary)
            .rotationEffect(.degrees(rotation))
    }

    /// Tumble animation: rotate both dice while rapidly cycling random faces,
    /// then snap to the real `left`/`right` values. Both dice land together
    /// with a single landing haptic.
    private func roll(toLeft targetLeft: Int, toRight targetRight: Int) {
        withAnimation(.easeOut(duration: 0.85)) {
            rotationLeft += 720
            rotationRight += 720
        }

        Task { @MainActor in
            for _ in 0..<7 {
                displayLeft = Int.random(in: 1...6)
                displayRight = Int.random(in: 1...6)
                try? await Task.sleep(for: .milliseconds(100))
            }

            displayLeft = targetLeft
            displayRight = targetRight
            HapticManager.shared.lightImpact()
        }
    }
}

#Preview {
    DiceCard(left: 4, right: 6, rollID: 0, onRoll: {})
        .frame(width: 160, height: 64)
        .padding()
        .background(Color.black)
}
