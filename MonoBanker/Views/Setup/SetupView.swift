//
//  SetupView.swift
//  MonoBanker
//

import SwiftUI

struct SetupView: View {
    @Environment(\.dismiss) private var dismiss
    let onStart: (_ players: [Player], _ startingBalance: Int) -> Void

    @State private var startingBalanceText: String = "1500"
    @State private var draftPlayers: [Player] = []
    @State private var newPlayerName: String = ""
    @State private var newPlayerColor: PlayerColor = .red
    @FocusState private var newNameFocused: Bool

    private var startingBalance: Int {
        Int(startingBalanceText.filter(\.isNumber)) ?? 0
    }

    private var canStart: Bool {
        draftPlayers.count >= 2 && startingBalance > 0
    }

    private var usedColors: Set<PlayerColor> {
        Set(draftPlayers.map(\.color))
    }

    private var nextAvailableColor: PlayerColor {
        PlayerColor.allCases.first { !usedColors.contains($0) } ?? .red
    }

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxl) {
                        startingBalanceSection
                        playersSection
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.top, DesignSystem.Spacing.lg)
                    .padding(.bottom, 120)
                }

                startButton
            }
        }
        .onAppear {
            if draftPlayers.isEmpty { newPlayerColor = nextAvailableColor }
        }
    }

    // MARK: - Header

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

            Text("New Game")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textPrimary)

            Spacer()

            Spacer().frame(width: 44)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, 2)
        .padding(.bottom, DesignSystem.Spacing.md)
    }

    // MARK: - Starting balance

    private var startingBalanceSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("STARTING BALANCE")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.textSecondary)
                .kerning(1.2)

            Card {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text("$")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.brandPrimary)

                    TextField("1500", text: $startingBalanceText)
                        .keyboardType(.numberPad)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .tint(.brandPrimary)
                }
            }
        }
    }

    // MARK: - Players

    private var playersSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text("PLAYERS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .kerning(1.2)

                Spacer()

                Text("\(draftPlayers.count)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .kerning(1.2)
            }

            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(draftPlayers) { player in
                    PlayerRow(player: player) {
                        HapticManager.shared.lightImpact()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            draftPlayers.removeAll { $0.id == player.id }
                            newPlayerColor = nextAvailableColor
                        }
                    }
                }

                addPlayerCard
            }
        }
    }

    private var addPlayerCard: some View {
        Card {
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    Circle()
                        .fill(newPlayerColor.color)
                        .frame(width: 18, height: 18)

                    TextField("Player name", text: $newPlayerName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .tint(.brandPrimary)
                        .focused($newNameFocused)
                        .submitLabel(.done)
                        .onSubmit(addPlayer)

                    Button {
                        addPlayer()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(canAddPlayer ? .black : .textSecondary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(canAddPlayer ? Color.brandPrimary : Color.gray.opacity(0.2))
                            )
                    }
                    .disabled(!canAddPlayer)
                }

                // Color swatches
                HStack(spacing: 10) {
                    ForEach(PlayerColor.allCases) { color in
                        ColorSwatch(
                            color: color,
                            isSelected: color == newPlayerColor,
                            isUsed: usedColors.contains(color)
                        ) {
                            guard !usedColors.contains(color) else { return }
                            HapticManager.shared.selectionChanged()
                            newPlayerColor = color
                        }
                    }
                }
            }
        }
    }

    private var canAddPlayer: Bool {
        !newPlayerName.trimmingCharacters(in: .whitespaces).isEmpty
            && !usedColors.contains(newPlayerColor)
    }

    private func addPlayer() {
        let trimmed = newPlayerName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !usedColors.contains(newPlayerColor) else { return }
        HapticManager.shared.lightImpact()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            draftPlayers.append(Player(name: trimmed, color: newPlayerColor, balance: 0))
            newPlayerName = ""
            newPlayerColor = nextAvailableColor
        }
        newNameFocused = true
    }

    // MARK: - Start

    private var startButton: some View {
        VStack {
            Button {
                guard canStart else { return }
                HapticManager.shared.mediumImpact()
                let players = draftPlayers.map {
                    Player(id: $0.id, name: $0.name, color: $0.color, balance: startingBalance)
                }
                onStart(players, startingBalance)
            } label: {
                Text("Start Game")
            }
            .buttonStyle(PrimaryButtonStyle(isDisabled: !canStart))
            .disabled(!canStart)
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
}

// MARK: - PlayerRow

private struct PlayerRow: View {
    let player: Player
    let onDelete: () -> Void

    var body: some View {
        Card {
            HStack(spacing: DesignSystem.Spacing.md) {
                Circle()
                    .fill(player.color.color)
                    .frame(width: 18, height: 18)

                Text(player.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.textPrimary)

                Spacer()

                Button {
                    onDelete()
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.error)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.error.opacity(0.15))
                        )
                }
            }
        }
    }
}

// MARK: - ColorSwatch

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

#Preview {
    SetupView(onStart: { _, _ in })
        .environment(AppState())
}
