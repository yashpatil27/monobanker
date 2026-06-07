//
//  LaunchView.swift
//  MonoBanker
//

import SwiftUI

struct LaunchView: View {
    @Environment(AppState.self) private var appState
    let onNewGame: () -> Void
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Wordmark
            VStack(spacing: DesignSystem.Spacing.md) {
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 56, weight: .regular))
                    .foregroundStyle(Color.brandPrimary)

                Text("MonoBanker")
                    .font(.system(size: 36, weight: .semibold, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .kerning(-0.5)

                Text("Cash, for the table.")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            // Buttons
            VStack(spacing: DesignSystem.Spacing.md) {
                if appState.hasActiveSession {
                    Button {
                        HapticManager.shared.lightImpact()
                        onContinue()
                    } label: {
                        Text("Continue Game")
                    }
                    .buttonStyle(BrandButtonStyle())
                }

                Button {
                    HapticManager.shared.lightImpact()
                    onNewGame()
                } label: {
                    Text("New Game")
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.xxxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgPrimary.ignoresSafeArea())
    }
}

#Preview {
    LaunchView(onNewGame: {}, onContinue: {})
        .environment(AppState())
}
