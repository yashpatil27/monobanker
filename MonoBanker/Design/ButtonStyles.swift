//
//  ButtonStyles.swift
//  MonoBanker
//

import SwiftUI

// MARK: - Primary (filled white, black text)
struct PrimaryButtonStyle: ButtonStyle {
    let isDisabled: Bool
    let fullWidth: Bool
    let compact: Bool

    init(isDisabled: Bool = false, fullWidth: Bool = true, compact: Bool = false) {
        self.isDisabled = isDisabled
        self.fullWidth = fullWidth
        self.compact = compact
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.black)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, DesignSystem.Spacing.xxxl)
            .padding(.vertical, compact ? 10 : 18)
            .background(
                RoundedRectangle(cornerRadius: compact ? DesignSystem.CornerRadius.md : DesignSystem.CornerRadius.lg)
                    .fill(isDisabled ? Color.gray.opacity(DesignSystem.Opacity.medium) : Color.white)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

// MARK: - Brand (pink outlined ghost)
struct BrandButtonStyle: ButtonStyle {
    let isDisabled: Bool
    let fullWidth: Bool
    let compact: Bool

    init(isDisabled: Bool = false, fullWidth: Bool = true, compact: Bool = false) {
        self.isDisabled = isDisabled
        self.fullWidth = fullWidth
        self.compact = compact
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.brandPrimary)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, DesignSystem.Spacing.xxxl)
            .padding(.vertical, compact ? 10 : 18)
            .background(
                RoundedRectangle(cornerRadius: compact ? DesignSystem.CornerRadius.md : DesignSystem.CornerRadius.lg)
                    .fill(Color.brandPrimary.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: compact ? DesignSystem.CornerRadius.md : DesignSystem.CornerRadius.lg)
                            .stroke(Color.brandPrimary.opacity(0.6), lineWidth: 1.5)
                    )
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

// MARK: - Destructive (red ghost)
struct DestructiveButtonStyle: ButtonStyle {
    let fullWidth: Bool
    init(fullWidth: Bool = true) { self.fullWidth = fullWidth }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.error)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, DesignSystem.Spacing.xxxl)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(Color.error.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .stroke(Color.error.opacity(0.5), lineWidth: 1)
                    )
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}

// MARK: - Ghost (text-only)
struct GhostButtonStyle: ButtonStyle {
    let tint: Color
    let fullWidth: Bool
    init(tint: Color = .textSecondary, fullWidth: Bool = true) {
        self.tint = tint
        self.fullWidth = fullWidth
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(tint)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, DesignSystem.Spacing.xxxl)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .stroke(tint.opacity(DesignSystem.Opacity.medium),
                            lineWidth: DesignSystem.BorderWidth.thin)
            )
            .opacity(configuration.isPressed ? 0.7 : 1.0)
    }
}
