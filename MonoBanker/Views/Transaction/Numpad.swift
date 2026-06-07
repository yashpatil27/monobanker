//
//  Numpad.swift
//  MonoBanker
//

import SwiftUI

enum NumpadKey: Hashable {
    case digit(Int)
    case doubleZero
    case backspace
}

struct Numpad: View {
    let onKey: (NumpadKey) -> Void

    private let rows: [[NumpadKey]] = [
        [.digit(1), .digit(2), .digit(3)],
        [.digit(4), .digit(5), .digit(6)],
        [.digit(7), .digit(8), .digit(9)],
        [.doubleZero, .digit(0), .backspace]
    ]

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(rows.indices, id: \.self) { rowIdx in
                HStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(rows[rowIdx], id: \.self) { key in
                        NumpadButton(key: key) {
                            HapticManager.shared.selectionChanged()
                            onKey(key)
                        }
                    }
                }
            }
        }
    }
}

private struct NumpadButton: View {
    let key: NumpadKey
    let action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .fill(pressed ? Color.brandPrimary.opacity(0.18) : Color.gray.opacity(0.08))

                label
                    .foregroundColor(.textPrimary)
            }
            .frame(height: 64)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !pressed {
                        withAnimation(.easeOut(duration: 0.08)) { pressed = true }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.15)) { pressed = false }
                }
        )
    }

    @ViewBuilder
    private var label: some View {
        switch key {
        case .digit(let n):
            Text("\(n)")
                .font(.system(size: 26, weight: .medium, design: .rounded))
        case .doubleZero:
            Text("00")
                .font(.system(size: 24, weight: .medium, design: .rounded))
        case .backspace:
            Image(systemName: "delete.left")
                .font(.system(size: 22, weight: .medium))
        }
    }
}
