//
//  TransactionOverlay.swift
//  MonoBanker
//

import SwiftUI

struct TransactionOverlay: View {
    let session: GameSession
    let payer: Participant
    let recipient: Participant
    let onCancel: () -> Void
    let onConfirm: (Int) -> Void

    @State private var amount: Int = 0
    @State private var shake: CGFloat = 0

    private var payerName: String { session.name(for: payer) }
    private var recipientName: String { session.name(for: recipient) }
    private var payerColor: Color { color(for: payer) }
    private var recipientColor: Color { color(for: recipient) }
    private var payerBalance: Int? { session.balance(of: payer) }

    /// True when one side is `.all` — changes input semantics to per-player.
    private var involvesAll: Bool { payer.isAll || recipient.isAll }

    /// Number of "others" when one side is All (otherwise 1).
    private var othersCount: Int {
        if recipient.isAll { return session.othersCount(opposite: payer) }
        if payer.isAll     { return session.othersCount(opposite: recipient) }
        return 1
    }

    /// The total money moving in the transaction (per-player × N for All-side, else `amount`).
    private var totalAmount: Int { involvesAll ? amount * othersCount : amount }

    private var canConfirm: Bool {
        guard amount > 0 else { return false }
        return session.canPay(from: payer, to: recipient, totalAmount: totalAmount)
    }

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                Spacer(minLength: 0)

                paymentRow
                    .padding(.bottom, DesignSystem.Spacing.xxl)

                amountDisplay
                    .padding(.bottom, DesignSystem.Spacing.xs)

                balanceContext
                    .padding(.bottom, DesignSystem.Spacing.xxl)

                Spacer(minLength: 0)

                Numpad { key in
                    handleKey(key)
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)

                actionButtons
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.top, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.xl)
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack {
            Text("PAYING")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.textSecondary)
                .kerning(1.6)
            Spacer()
            Button {
                HapticManager.shared.lightImpact()
                onCancel()
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

    private var paymentRow: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            participantTag(name: payerName, color: payerColor)

            Image(systemName: "arrow.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textSecondary)

            participantTag(name: recipientName, color: recipientColor)
        }
    }

    private func participantTag(name: String, color: Color) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textPrimary)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .background(
            Capsule().fill(Color.gray.opacity(0.12))
                .overlay(Capsule().stroke(Color.gray.opacity(0.25), lineWidth: 1))
        )
    }

    private var amountDisplay: some View {
        Text("$\(amount)")
            .font(.system(size: 64, weight: .semibold, design: .rounded))
            .foregroundColor(.brandPrimary)
            .contentTransition(.numericText(value: Double(amount)))
            .animation(.easeOut(duration: 0.2), value: amount)
            .monospacedDigit()
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .offset(x: shake)
    }

    @ViewBuilder
    private var balanceContext: some View {
        VStack(spacing: 4) {
            // Total breakdown when All is involved.
            if involvesAll, amount > 0 {
                Text("$\(amount) × \(othersCount) = $\(totalAmount) total")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textSecondary)
                    .monospacedDigit()
            }

            // Payer affordability hint.
            if case .player = payer, let bal = payerBalance {
                let exceeds = totalAmount > bal
                Text("\(payerName) balance: $\(bal)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(exceeds ? .error : .textSecondary)
                    .monospacedDigit()
            } else if payer.isBank {
                Text("Bank funds: unlimited")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.textSecondary)
            } else if payer.isAll {
                let mins = session.players
                    .filter {
                        if case .player(let id) = recipient { return $0.id != id }
                        return true
                    }
                    .map(\.balance)
                if let minBal = mins.min() {
                    let exceeds = amount > minBal
                    Text("Lowest balance: $\(minBal)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(exceeds ? .error : .textSecondary)
                        .monospacedDigit()
                }
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Button {
                HapticManager.shared.lightImpact()
                onCancel()
            } label: {
                Text("Cancel")
            }
            .buttonStyle(GhostButtonStyle(tint: .textSecondary, fullWidth: true))

            Button {
                guard canConfirm else {
                    triggerShake()
                    return
                }
                HapticManager.shared.mediumImpact()
                onConfirm(totalAmount)
            } label: {
                Text("Confirm")
            }
            .buttonStyle(PrimaryButtonStyle(isDisabled: !canConfirm, fullWidth: true))
            .disabled(!canConfirm)
        }
    }

    // MARK: - Helpers

    private func color(for participant: Participant) -> Color {
        switch participant {
        case .bank: return .brandPrimary
        case .all:  return .white
        case .player(let id): return session.player(for: id)?.color.color ?? .brandPrimary
        }
    }

    private func handleKey(_ key: NumpadKey) {
        switch key {
        case .digit(let n):
            let next = amount * 10 + n
            if next <= 9_999_999 { amount = next }
        case .tripleZero:
            let next = amount * 1000
            if next <= 9_999_999 { amount = next }
        case .backspace:
            amount = amount / 10
        }
    }

    private func triggerShake() {
        HapticManager.shared.warning()
        withAnimation(.easeInOut(duration: 0.05).repeatCount(4, autoreverses: true)) {
            shake = 8
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation { shake = 0 }
        }
    }
}
