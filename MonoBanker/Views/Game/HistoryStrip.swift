//
//  HistoryStrip.swift
//  MonoBanker
//

import SwiftUI

struct HistoryStrip: View {
    let session: GameSession
    let onTap: () -> Void

    private var recent: [Transaction] {
        Array(session.transactions.suffix(2).reversed())
    }

    var body: some View {
        Button {
            HapticManager.shared.lightImpact()
            onTap()
        } label: {
            Card(padding: false) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    HStack {
                        Text("RECENT")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .kerning(1.4)
                        Spacer()
                        Image(systemName: "chevron.up")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.textSecondary)
                    }

                    if recent.isEmpty {
                        Text("No transactions yet")
                            .font(.system(size: 13))
                            .foregroundColor(.textSecondary)
                    } else {
                        ForEach(recent) { tx in
                            row(for: tx)
                        }
                    }
                }
                .padding(DesignSystem.Spacing.md)
            }
        }
        .buttonStyle(.plain)
    }

    private func row(for tx: Transaction) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Text(session.name(for: tx.from))
                .foregroundColor(.textPrimary)
            Image(systemName: "arrow.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.textSecondary)
            Text(session.name(for: tx.to))
                .foregroundColor(.textPrimary)
            Spacer()
            Text("$\(tx.amount)")
                .foregroundColor(.brandPrimary)
                .monospacedDigit()
        }
        .font(.system(size: 13, weight: .medium))
    }
}
