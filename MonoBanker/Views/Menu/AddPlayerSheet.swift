//
//  AddPlayerSheet.swift
//  MonoBanker
//
//  Lets the user add a player mid-game. Mirrors SetupView's add-player UX.
//

import SwiftUI

struct AddPlayerSheet: View {
    let usedColors: Set<PlayerColor>
    let onAdd: (_ name: String, _ color: PlayerColor) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var selectedColor: PlayerColor
    @FocusState private var nameFocused: Bool

    init(usedColors: Set<PlayerColor>,
         onAdd: @escaping (_ name: String, _ color: PlayerColor) -> Void) {
        self.usedColors = usedColors
        self.onAdd = onAdd
        // Default-pick the first available color.
        let available = PlayerColor.allCases.first { !usedColors.contains($0) } ?? .red
        _selectedColor = State(initialValue: available)
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
    }

    private var canAdd: Bool {
        !trimmedName.isEmpty && !usedColors.contains(selectedColor)
    }

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        Card {
                            VStack(spacing: DesignSystem.Spacing.md) {
                                HStack(spacing: DesignSystem.Spacing.md) {
                                    Circle()
                                        .fill(selectedColor.color)
                                        .frame(width: 18, height: 18)

                                    TextField("Player name", text: $name)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.textPrimary)
                                        .tint(.brandPrimary)
                                        .focused($nameFocused)
                                        .submitLabel(.done)
                                        .onSubmit { submitIfAllowed() }
                                }

                                HStack(spacing: 10) {
                                    ForEach(PlayerColor.allCases) { color in
                                        ColorSwatch(
                                            color: color,
                                            isSelected: color == selectedColor,
                                            isUsed: usedColors.contains(color)
                                        ) {
                                            guard !usedColors.contains(color) else { return }
                                            HapticManager.shared.selectionChanged()
                                            selectedColor = color
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.top, DesignSystem.Spacing.md)
                }

                addButton
            }
        }
        .onAppear { nameFocused = true }
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

            Text("Add Player")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textPrimary)

            Spacer()

            Spacer().frame(width: 44)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.sm)
    }

    private var addButton: some View {
        Button {
            submitIfAllowed()
        } label: {
            Text("Add Player")
        }
        .buttonStyle(PrimaryButtonStyle(isDisabled: !canAdd))
        .disabled(!canAdd)
        .padding(.horizontal, DesignSystem.Spacing.xl)
        .padding(.bottom, DesignSystem.Spacing.xl)
    }

    private func submitIfAllowed() {
        guard canAdd else { return }
        HapticManager.shared.mediumImpact()
        onAdd(trimmedName, selectedColor)
        dismiss()
    }
}

// MARK: - ColorSwatch (private helper)

private struct ColorSwatch: View {
    let color: PlayerColor
    let isSelected: Bool
    let isUsed: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(color.color)
                    .frame(width: 26, height: 26)
                    .opacity(isUsed && !isSelected ? 0.25 : 1.0)

                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: 2)
                        .frame(width: 34, height: 34)
                }
            }
            .frame(width: 36, height: 36)
        }
        .disabled(isUsed && !isSelected)
        .buttonStyle(.plain)
    }
}
