//
//  LaunchView.swift
//  MonoBanker
//

import SwiftUI

struct LaunchView: View {
    @Environment(AppState.self) private var appState
    let onNewGame: () -> Void
    let onContinue: () -> Void
    @State private var showingSettings = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Wordmark
            VStack(spacing: DesignSystem.Spacing.xs) {
                Image("AppIconImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 112, height: 112)
                    .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.4), radius: 18, y: 7)
                    // Pull the title up to compensate for the icon's built-in bottom padding
                    // (the visible building doesn't reach the bottom of the icon's frame).
                    .padding(.bottom, -16)

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

                HStack(spacing: DesignSystem.Spacing.md) {
                    Button {
                        HapticManager.shared.lightImpact()
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .frame(width: 55, height: 55)
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

                    Button {
                        HapticManager.shared.lightImpact()
                        onNewGame()
                    } label: {
                        Text("New Game")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.xxxl)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.bgPrimary.ignoresSafeArea())
        .fullScreenCover(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

#Preview {
    LaunchView(onNewGame: {}, onContinue: {})
        .environment(AppState())
        .environment(AppSettings())
}
