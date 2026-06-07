//
//  HistorySheet.swift
//  MonoBanker
//

import SwiftUI

struct HistorySheet: View {
    @Bindable var session: GameSession
    @Environment(\.dismiss) private var dismiss

    private var reversed: [Transaction] {
        Array(session.transactions.reversed())
    }

    private var hasTransactions: Bool { !session.transactions.isEmpty }

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                if hasTransactions {
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(reversed) { tx in
                                row(for: tx)
                            }
                        }
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                        .padding(.top, DesignSystem.Spacing.md)
                        .padding(.bottom, 120)
                    }
                } else {
                    Spacer()
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "tray")
                            .font(.system(size: 32, weight: .light))
                            .foregroundColor(.textSecondary)
                        Text("No transactions yet")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                }

                undoFooter
            }
        }
    }

    // MARK: - Sections

    private var header: some View {
        HStack {
            Button {
                HapticManager.shared.lightImpact()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.brandPrimary)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }

            Spacer()

            Text("History")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textPrimary)

            Spacer()

            Spacer().frame(width: 44)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, DesignSystem.Spacing.md)
    }

    private func row(for tx: Transaction) -> some View {
        Card {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    participantInline(participant: tx.from)
                    Image(systemName: "arrow.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.textSecondary)
                    participantInline(participant: tx.to)

                    Spacer()

                    Text("$\(tx.amount)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.brandPrimary)
                        .monospacedDigit()
                }

                Text(relativeTime(for: tx.timestamp))
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.textSecondary)
            }
        }
    }

    private func participantInline(participant: Participant) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color(for: participant))
                .frame(width: 8, height: 8)
            Text(session.name(for: participant))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.textPrimary)
        }
    }

    private var undoFooter: some View {
        VStack {
            Button {
                guard hasTransactions else { return }
                HapticManager.shared.mediumImpact()
                _ = session.undoLast()
                if session.transactions.isEmpty {
                    // Stay open; let the user dismiss manually.
                }
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "arrow.uturn.backward")
                    Text("Undo Last")
                }
            }
            .buttonStyle(BrandButtonStyle(isDisabled: !hasTransactions))
            .disabled(!hasTransactions)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
        .background(
            LinearGradient(
                colors: [Color.bgPrimary.opacity(0), Color.bgPrimary],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 120)
            .allowsHitTesting(false),
            alignment: .bottom
        )
    }

    // MARK: - Helpers

    private func color(for participant: Participant) -> Color {
        switch participant {
        case .bank: return .brandPrimary
        case .all:  return .white
        case .player(let id): return session.player(for: id)?.color.color ?? .brandPrimary
        }
    }

    private func relativeTime(for date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
