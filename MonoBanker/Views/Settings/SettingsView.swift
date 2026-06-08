//
//  SettingsView.swift
//  MonoBanker
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var showingClearConfirm = false

    var body: some View {
        @Bindable var settings = settings

        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    ScrollView {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxl) {
                            startingBalanceSection(balance: $settings.defaultStartingBalance)
                            defaultPlayersSection
                            behaviorSection(hapticsEnabled: $settings.hapticsEnabled)
                            maintenanceSection
                            infoSection
                        }
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                        .padding(.vertical, DesignSystem.Spacing.md)
                        .padding(.bottom, DesignSystem.Spacing.xxxl)
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .alert("Clear saved game?", isPresented: $showingClearConfirm) {
            Button("Clear", role: .destructive) {
                HapticManager.shared.mediumImpact()
                appState.endGame()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Any in-progress game will be wiped.")
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

            Text("Settings")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textPrimary)

            Spacer()

            Spacer().frame(width: 44)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, 2)
        .padding(.bottom, DesignSystem.Spacing.md)
    }

    // MARK: - Starting Balance

    @ViewBuilder
    private func startingBalanceSection(balance: Binding<Int>) -> some View {
        sectionHeader("DEFAULT STARTING BALANCE")
        Card {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Text("$")
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundColor(.brandPrimary)

                TextField(
                    "1500",
                    text: Binding(
                        get: { String(balance.wrappedValue) },
                        set: { newValue in
                            let digits = newValue.filter(\.isNumber)
                            balance.wrappedValue = Int(digits) ?? 0
                        }
                    )
                )
                .keyboardType(.numberPad)
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .foregroundColor(.textPrimary)
                .tint(.brandPrimary)
            }
        }
    }

    // MARK: - Default Players

    @ViewBuilder
    private var defaultPlayersSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text("DEFAULT PLAYERS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .kerning(1.2)

                Spacer()

                Text("\(settings.defaultPlayers.count) / \(AppSettings.maxDefaultPlayers)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .kerning(1.2)
            }

            Text("These pre-fill the New Game screen so you don't have to type them every time.")
                .font(.system(size: 12))
                .foregroundColor(.textSecondary)
                .padding(.bottom, DesignSystem.Spacing.xs)

            VStack(spacing: DesignSystem.Spacing.sm) {
                ForEach(settings.defaultPlayers) { player in
                    DefaultPlayerRow(player: player) {
                        HapticManager.shared.lightImpact()
                        withAnimation(.easeInOut(duration: 0.2)) {
                            settings.removeDefaultPlayer(id: player.id)
                        }
                    }
                }

                if settings.canAddDefaultPlayer {
                    AddDefaultPlayerCard()
                }
            }
        }
    }

    // MARK: - Behavior

    @ViewBuilder
    private func behaviorSection(hapticsEnabled: Binding<Bool>) -> some View {
        sectionHeader("BEHAVIOR")
        Card {
            Toggle(isOn: hapticsEnabled) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    IconContainer(systemName: "iphone.radiowaves.left.and.right",
                                  tint: .textPrimary,
                                  backgroundColor: Color.gray.opacity(0.15))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Haptic feedback")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.textPrimary)
                        Text("Vibration on drag, drop, and confirm.")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }
                }
            }
            .tint(.brandPrimary)
        }
    }

    // MARK: - Maintenance

    @ViewBuilder
    private var maintenanceSection: some View {
        sectionHeader("MAINTENANCE")
        Card(padding: false) {
            Button {
                HapticManager.shared.lightImpact()
                showingClearConfirm = true
            } label: {
                HStack(spacing: DesignSystem.Spacing.md) {
                    IconContainer(systemName: "trash",
                                  tint: .error,
                                  backgroundColor: Color.error.opacity(0.15))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Clear saved game")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.error)
                        Text(appState.hasActiveSession
                             ? "A game is currently in progress."
                             : "No active game.")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer()
                }
                .padding(DesignSystem.Spacing.md)
            }
            .buttonStyle(.plain)
            .disabled(!appState.hasActiveSession)
            .opacity(appState.hasActiveSession ? 1 : 0.5)
        }
    }

    // MARK: - Info

    @ViewBuilder
    private var infoSection: some View {
        sectionHeader("INFO")
        VStack(spacing: DesignSystem.Spacing.sm) {
            NavigationLink {
                HowToUseView()
            } label: {
                infoRow(icon: "book", title: "How to use MonoBanker")
            }
            .buttonStyle(.plain)

            NavigationLink {
                AboutView()
            } label: {
                infoRow(icon: "info.circle", title: "About", trailing: AboutView.versionString)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.textSecondary)
            .kerning(1.2)
    }

    private func infoRow(icon: String, title: String, trailing: String? = nil) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            IconContainer(systemName: icon,
                          tint: .textPrimary,
                          backgroundColor: Color.gray.opacity(0.15))
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textPrimary)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.system(size: 13))
                    .foregroundColor(.textSecondary)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.textSecondary)
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(Color.gray.opacity(DesignSystem.Opacity.subtle))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .stroke(Color.gray.opacity(DesignSystem.Opacity.medium), lineWidth: 1)
                )
        )
    }
}

// MARK: - DefaultPlayerRow

private struct DefaultPlayerRow: View {
    let player: DefaultPlayer
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

                Button(action: onDelete) {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.error)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color.error.opacity(0.15)))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - AddDefaultPlayerCard

private struct AddDefaultPlayerCard: View {
    @Environment(AppSettings.self) private var settings
    @State private var name: String = ""
    @State private var selectedColor: PlayerColor = .red
    @FocusState private var nameFocused: Bool

    private var canAdd: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && !settings.usedDefaultColors.contains(selectedColor)
    }

    var body: some View {
        Card {
            VStack(spacing: DesignSystem.Spacing.md) {
                HStack(spacing: DesignSystem.Spacing.md) {
                    Circle()
                        .fill(selectedColor.color)
                        .frame(width: 18, height: 18)

                    TextField("Name", text: $name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .tint(.brandPrimary)
                        .focused($nameFocused)
                        .submitLabel(.done)
                        .onSubmit { add() }

                    Button(action: add) {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(canAdd ? .black : .textSecondary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle().fill(canAdd ? Color.brandPrimary : Color.gray.opacity(0.2))
                            )
                    }
                    .disabled(!canAdd)
                    .buttonStyle(.plain)
                }

                HStack(spacing: 10) {
                    ForEach(PlayerColor.allCases) { color in
                        SettingsColorSwatch(
                            color: color,
                            isSelected: color == selectedColor,
                            isUsed: settings.usedDefaultColors.contains(color)
                        ) {
                            guard !settings.usedDefaultColors.contains(color) else { return }
                            HapticManager.shared.selectionChanged()
                            selectedColor = color
                        }
                    }
                }
            }
        }
        .onAppear {
            if let next = settings.nextAvailableColor() {
                selectedColor = next
            }
        }
    }

    private func add() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !settings.usedDefaultColors.contains(selectedColor) else { return }
        HapticManager.shared.lightImpact()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            settings.addDefaultPlayer(name: trimmed, color: selectedColor)
            name = ""
            if let next = settings.nextAvailableColor() {
                selectedColor = next
            }
        }
        nameFocused = true
    }
}

// MARK: - ColorSwatch

private struct SettingsColorSwatch: View {
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

// MARK: - HowToUseView

struct HowToUseView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                    instruction(
                        index: 1,
                        title: "Start a game",
                        body: "Tap New Game, add at least 2 players, pick their colors, and set the starting balance."
                    )
                    instruction(
                        index: 2,
                        title: "Drag to pay",
                        body: "Touch any card and drag it onto another. The payer is the card you dragged; the recipient is the one you dropped on."
                    )
                    instruction(
                        index: 3,
                        title: "Bank",
                        body: "The Bank has unlimited funds. Drag a player onto Bank to pay (taxes, fees), or drag Bank onto a player to give (passing GO)."
                    )
                    instruction(
                        index: 4,
                        title: "All",
                        body: "Drag a player onto All to split a payment between everyone else, or drag All onto a player to collect from everyone else. Bank and All can't interact."
                    )
                    instruction(
                        index: 5,
                        title: "Rearrange & manage",
                        body: "Tap the rearrange button (the grid icon) to enter rearrange mode. Drag cards to reorder, tap the X to remove a player, or use the + button to add a player mid-game."
                    )
                    instruction(
                        index: 6,
                        title: "Undo and history",
                        body: "Tap the recent strip at the bottom or open History from the menu to see all transactions. Use Undo Last to reverse the most recent one."
                    )
                    instruction(
                        index: 7,
                        title: "End or restart",
                        body: "From the menu, Restart resets every balance and clears history. End Game wipes the session entirely and returns to the launch screen."
                    )
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.vertical, DesignSystem.Spacing.md)
                    .padding(.bottom, DesignSystem.Spacing.xxxl)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack {
            Button {
                HapticManager.shared.lightImpact()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.brandPrimary)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }

            Spacer()

            Text("How to use")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textPrimary)

            Spacer()

            Spacer().frame(width: 44)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, 2)
        .padding(.bottom, DesignSystem.Spacing.md)
    }

    private func instruction(index: Int, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.18))
                    .frame(width: 32, height: 32)
                Text("\(index)")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.brandPrimary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.textPrimary)
                Text(body)
                    .font(.system(size: 14))
                    .foregroundColor(.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - AboutView

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    static var versionString: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        return "v\(version)"
    }

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                VStack(spacing: DesignSystem.Spacing.lg) {
                    Spacer()

                    Image("AppIconImage")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 112, height: 112)
                        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))

                    Text("MonoBanker")
                        .font(.system(size: 28, weight: .semibold, design: .rounded))
                        .foregroundColor(.textPrimary)

                    Text(AboutView.versionString)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.textSecondary)

                    Text("Cash, for the table.")
                        .font(.system(size: 14))
                        .foregroundColor(.textSecondary)
                        .padding(.top, DesignSystem.Spacing.sm)

                    Spacer()
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var header: some View {
        HStack {
            Button {
                HapticManager.shared.lightImpact()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.brandPrimary)
                    .frame(width: 44, height: 44)
                    .contentShape(Circle())
            }

            Spacer()

            Text("About")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.textPrimary)

            Spacer()

            Spacer().frame(width: 44)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, 2)
        .padding(.bottom, DesignSystem.Spacing.md)
    }
}
