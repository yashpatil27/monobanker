//
//  ParticipantCard.swift
//  MonoBanker
//

import SwiftUI

struct ParticipantCard: View {
    let participant: Participant
    let name: String
    let balance: Int?        // nil for Bank/All
    let lastChange: Int?     // signed delta from the player's last transaction; nil for none/Bank/All
    let color: Color         // accent color (player color or brand pink for bank)
    let isDragging: Bool     // this card is being dragged
    let isTargeted: Bool     // this card is a valid drop target being hovered
    let isInactive: Bool     // this card cannot be a target (i.e. it's the dragged card)
    var isWobbling: Bool = false                  // iOS-homescreen-style wobble (rearrange mode)
    var showRemove: Bool = false                  // show the corner remove X (rearrange mode)
    var onRemove: (() -> Void)? = nil             // tap handler for the remove X

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Top row: color dot + name
            HStack(spacing: DesignSystem.Spacing.sm) {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)

                Text(name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Spacer(minLength: 0)
            }

            Spacer(minLength: 0)

            // Balance or Bank/All tag
            if let balance {
                VStack(alignment: .leading, spacing: 2) {
                    Text("$\(balance)")
                        .font(.system(size: 28, weight: .medium, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .contentTransition(.numericText(value: Double(balance)))
                        .animation(.easeOut(duration: 0.3), value: balance)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)

                    Text(deltaDisplay(lastChange))
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(deltaColor(lastChange))
                        .contentTransition(.numericText(value: Double(lastChange ?? 0)))
                        .animation(.easeOut(duration: 0.3), value: lastChange)
                        .monospacedDigit()
                        .lineLimit(1)
                }
            } else {
                Text(noBalancePlaceholder)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(color)
                    .kerning(1.4)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(cardBackground)
        .overlay(targetOverlay)
        .overlay(alignment: .topTrailing) { removeButton }
        .scaleEffect(isDragging ? 1.04 : (isTargeted ? 1.02 : 1.0))
        .opacity(isInactive && !isDragging ? 0.4 : 1.0)
        .shadow(color: shadowColor, radius: isDragging ? 18 : 0, x: 0, y: isDragging ? 8 : 0)
        .modifier(WobbleModifier(isActive: isWobbling))
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
        .animation(.easeInOut(duration: 0.15), value: isTargeted)
        .animation(.easeInOut(duration: 0.15), value: isInactive)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Drag onto another card to pay")
    }

    @ViewBuilder
    private var removeButton: some View {
        if showRemove, let onRemove {
            Button {
                HapticManager.shared.lightImpact()
                onRemove()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 22, height: 22)
                    .background(
                        Circle()
                            .fill(Color.black)
                            .overlay(Circle().stroke(Color.white.opacity(0.85), lineWidth: 1.5))
                    )
            }
            .buttonStyle(.plain)
            .offset(x: 7, y: -7)
            .transition(.scale.combined(with: .opacity))
        }
    }

    private var accessibilityDescription: String {
        if let balance {
            return "\(name), balance $\(balance)"
        } else if participant.isAll {
            return "\(name), every other player"
        } else {
            return "\(name), unlimited funds"
        }
    }

    private var noBalancePlaceholder: String {
        switch participant {
        case .all: return "EVERYONE"
        case .bank: return "UNLIMITED"
        case .player: return ""
        }
    }

    private func deltaDisplay(_ delta: Int?) -> String {
        guard let delta else { return "$0" }
        let sign = delta >= 0 ? "+" : "-"
        return "\(sign)$\(abs(delta))"
    }

    private func deltaColor(_ delta: Int?) -> Color {
        guard let delta, delta != 0 else { return .textSecondary }
        return delta > 0 ? .success : .error
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
            .fill(
                isTargeted
                    ? Color.brandPrimary.opacity(0.12)
                    : Color.gray.opacity(DesignSystem.Opacity.subtle)
            )
    }

    private var targetOverlay: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
            .stroke(
                isTargeted ? Color.brandPrimary : Color.gray.opacity(DesignSystem.Opacity.medium),
                lineWidth: isTargeted ? 1.5 : 1
            )
    }

    private var shadowColor: Color {
        isDragging ? Color.brandPrimary.opacity(0.35) : .clear
    }
}

// MARK: - Wobble modifier (iOS home-screen-style)

private struct WobbleModifier: ViewModifier {
    let isActive: Bool
    /// Per-instance phase offset so cards wobble independently rather than in lockstep.
    private let phaseOffset: Double = Double.random(in: 0..<(.pi * 2))

    func body(content: Content) -> some View {
        if isActive {
            TimelineView(.animation) { context in
                let t = context.date.timeIntervalSinceReferenceDate * 10 + phaseOffset
                content.rotationEffect(.degrees(sin(t) * 1.3))
            }
        } else {
            content
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        ParticipantCard(
            participant: .bank,
            name: "Bank",
            balance: nil,
            lastChange: nil,
            color: .brandPrimary,
            isDragging: false,
            isTargeted: false,
            isInactive: false
        )
        ParticipantCard(
            participant: .player(UUID()),
            name: "Alice",
            balance: 1500,
            lastChange: 50,
            color: PlayerColor.sky.color,
            isDragging: false,
            isTargeted: true,
            isInactive: false
        )
    }
    .padding()
    .background(Color.black)
}
