//
//  MenuSheet.swift
//  MonoBanker
//

import SwiftUI

struct MenuSheet: View {
    let onShowHistory: () -> Void
    let onAddPlayer: () -> Void
    let onRestart: () -> Void
    let onEndGame: () -> Void

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: DesignSystem.Spacing.md) {
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 4)
                    .padding(.top, 8)

                VStack(spacing: DesignSystem.Spacing.sm) {
                    Button {
                        HapticManager.shared.lightImpact()
                        onShowHistory()
                    } label: {
                        row(icon: "list.bullet.rectangle", title: "View History", tint: .textPrimary)
                    }
                    .buttonStyle(.plain)

                    Button {
                        HapticManager.shared.lightImpact()
                        onAddPlayer()
                    } label: {
                        row(icon: "person.badge.plus", title: "Add Player", tint: .textPrimary)
                    }
                    .buttonStyle(.plain)

                    Button {
                        HapticManager.shared.lightImpact()
                        onRestart()
                    } label: {
                        row(icon: "arrow.counterclockwise", title: "Restart", tint: .brandPrimary)
                    }
                    .buttonStyle(.plain)

                    Button {
                        HapticManager.shared.lightImpact()
                        onEndGame()
                    } label: {
                        row(icon: "stop.circle", title: "End Game", tint: .error)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.md)

                Spacer()
            }
        }
    }

    private func row(icon: String, title: String, tint: Color) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            IconContainer(systemName: icon, tint: tint, backgroundColor: tint.opacity(0.15))
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(tint)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.textSecondary)
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(Color.gray.opacity(DesignSystem.Opacity.subtle))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .stroke(Color.gray.opacity(DesignSystem.Opacity.medium), lineWidth: 1)
                )
        )
    }
}
