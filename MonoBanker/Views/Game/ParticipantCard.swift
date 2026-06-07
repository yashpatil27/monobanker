//
//  ParticipantCard.swift
//  MonoBanker
//

import SwiftUI

struct ParticipantCard: View {
    let participant: Participant
    let name: String
    let balance: Int?        // nil for Bank
    let color: Color         // accent color (player color or brand pink for bank)
    let isDragging: Bool     // this card is being dragged
    let isTargeted: Bool     // this card is a valid drop target being hovered
    let isInactive: Bool     // this card cannot be a target (i.e. it's the dragged card)

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            // Top row: color dot + name
            HStack(spacing: DesignSystem.Spacing.sm) {
                Circle()
                    .fill(color)
                    .frame(width: 12, height: 12)

                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }

            Spacer(minLength: 0)

            // Balance or Bank tag
            if let balance {
                Text("$\(balance)")
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundColor(.textPrimary)
                    .contentTransition(.numericText(value: Double(balance)))
                    .animation(.easeOut(duration: 0.3), value: balance)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            } else {
                Text(noBalancePlaceholder)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(color)
                    .kerning(1.4)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(cardBackground)
        .overlay(targetOverlay)
        .scaleEffect(isDragging ? 1.04 : (isTargeted ? 1.02 : 1.0))
        .opacity(isInactive && !isDragging ? 0.4 : 1.0)
        .shadow(color: shadowColor, radius: isDragging ? 18 : 0, x: 0, y: isDragging ? 8 : 0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
        .animation(.easeInOut(duration: 0.15), value: isTargeted)
        .animation(.easeInOut(duration: 0.15), value: isInactive)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
        .accessibilityHint("Drag onto another card to pay")
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

#Preview {
    HStack(spacing: 12) {
        ParticipantCard(
            participant: .bank,
            name: "Bank",
            balance: nil,
            color: .brandPrimary,
            isDragging: false,
            isTargeted: false,
            isInactive: false
        )
        ParticipantCard(
            participant: .player(UUID()),
            name: "Alice",
            balance: 1500,
            color: PlayerColor.sky.color,
            isDragging: false,
            isTargeted: true,
            isInactive: false
        )
    }
    .padding()
    .background(Color.black)
}
