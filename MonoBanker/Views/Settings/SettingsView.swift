//
//  SettingsView.swift
//  MonoBanker
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var settings = settings

        NavigationStack {
            ZStack {
                Color.bgPrimary.ignoresSafeArea()

                VStack(spacing: 0) {
                    header

                    ScrollView {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxl) {
                            gameDefaultsSection
                            behaviorSection(hapticsEnabled: $settings.hapticsEnabled)
                            supportSection
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

    // MARK: - Game Defaults

    @ViewBuilder
    private var gameDefaultsSection: some View {
        @Bindable var settings = settings

        sectionHeader("GAME PREFERENCES")
        VStack(spacing: DesignSystem.Spacing.sm) {
            NavigationLink {
                DefaultBalanceView()
            } label: {
                infoRow(icon: "banknote", title: "Starting Balance") {
                    HStack(spacing: 0) {
                        CurrencySymbol()
                        Text(settings.defaultStartingBalance.formatted())
                    }
                    .monospacedDigit()
                }
            }
            .buttonStyle(.plain)

            NavigationLink {
                DefaultPlayersView()
            } label: {
                infoRow(
                    icon: "person.2",
                    title: "Saved Players",
                    trailing: "\(settings.defaultPlayers.count) / \(AppSettings.maxDefaultPlayers)"
                )
            }
            .buttonStyle(.plain)

            NavigationLink {
                DisplayCurrencyView()
            } label: {
                infoRow(
                    icon: "dollarsign.circle",
                    title: "Display Currency",
                    trailing: settings.displayCurrency.displayName
                )
            }
            .buttonStyle(.plain)

            Card {
                HStack(spacing: DesignSystem.Spacing.md) {
                    IconContainer(systemName: "die.face.5",
                                  tint: .textPrimary,
                                  backgroundColor: Color.gray.opacity(0.15))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Show dice card")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.textPrimary)
                        Text("Adds a tappable two-die roller to the game grid.")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer(minLength: 0)
                    Toggle("", isOn: $settings.diceEnabled)
                        .labelsHidden()
                        .tint(.blue)
                        .fixedSize()
                        .scaleEffect(0.8)
                }
            }

            Card {
                HStack(spacing: DesignSystem.Spacing.md) {
                    IconContainer(systemName: "sparkles",
                                  tint: .textPrimary,
                                  backgroundColor: Color.gray.opacity(0.15))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Suggested amounts")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.textPrimary)
                        Text("Quick-pick chips above the numpad based on recent payments.")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                    }
                    Spacer(minLength: 0)
                    Toggle("", isOn: $settings.suggestedAmountsEnabled)
                        .labelsHidden()
                        .tint(.blue)
                        .fixedSize()
                        .scaleEffect(0.8)
                }
            }
        }
    }

    // MARK: - Behavior

    @ViewBuilder
    private func behaviorSection(hapticsEnabled: Binding<Bool>) -> some View {
        sectionHeader("BEHAVIOR")
        Card {
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
                Spacer(minLength: 0)
                Toggle("", isOn: hapticsEnabled)
                    .labelsHidden()
                    .tint(.blue)
                    .fixedSize()
                    .scaleEffect(0.8)
            }
        }
    }

    // MARK: - Support

    @ViewBuilder
    private var supportSection: some View {
        sectionHeader("SUPPORT")
        VStack(spacing: DesignSystem.Spacing.sm) {
            NavigationLink {
                SupportDevelopmentView()
            } label: {
                infoRow(icon: "heart.fill", title: "Support development")
            }
            .buttonStyle(.plain)
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
        infoRow(icon: icon, title: title) {
            if let trailing {
                Text(trailing)
            }
        }
    }

    private func infoRow<Trailing: View>(
        icon: String,
        title: String,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            IconContainer(systemName: icon,
                          tint: .textPrimary,
                          backgroundColor: Color.gray.opacity(0.15))
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.textPrimary)
            Spacer()
            trailing()
                .font(.system(size: 13))
                .foregroundColor(.textSecondary)
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

// MARK: - DefaultBalanceView

struct DefaultBalanceView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var settings = settings

        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("STARTING BALANCE")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .kerning(1.2)

                        Text("Pre-fills the starting balance on the New Game screen.")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                            .padding(.bottom, DesignSystem.Spacing.xs)

                        Card {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                CurrencySymbol()
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(.brandPrimary)

                                TextField(
                                    "1500",
                                    text: Binding(
                                        get: { String(settings.defaultStartingBalance) },
                                        set: { newValue in
                                            let digits = newValue.filter(\.isNumber)
                                            settings.defaultStartingBalance = Int(digits) ?? 0
                                        }
                                    )
                                )
                                .keyboardType(.numberPad)
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.textPrimary)
                                .tint(.brandPrimary)
                            }
                        }
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

            Text("Starting Balance")
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

// MARK: - DefaultPlayersView

struct DefaultPlayersView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        HStack {
                            Text("SAVED PLAYERS")
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

            Text("Saved Players")
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

                Spacer()

                // Wordmark — mirrors LaunchView's icon + title + tagline lockup.
                VStack(spacing: DesignSystem.Spacing.xs) {
                    Image("AppIconImage")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 112, height: 112)
                        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 26, style: .continuous)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.4), radius: 18, y: 7)
                        .padding(.bottom, -16)

                    Text("MonoBanker")
                        .font(.system(size: 36, weight: .semibold, design: .rounded))
                        .foregroundColor(.textPrimary)
                        .kerning(-0.5)

                    Text("Cash, for the table.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.textSecondary)

                    Text(AboutView.versionString)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .padding(.top, DesignSystem.Spacing.xs)
                }

                Spacer()
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

// MARK: - DisplayCurrencyView

struct DisplayCurrencyView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var settings = settings

        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("DISPLAY CURRENCY")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.textSecondary)
                            .kerning(1.2)

                        Text("Replaces the dollar sign across the app. Display only — amounts are not converted.")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)
                            .padding(.bottom, DesignSystem.Spacing.xs)

                        VStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(Currency.allCases) { currency in
                                CurrencyOptionRow(
                                    currency: currency,
                                    isSelected: settings.displayCurrency == currency
                                ) {
                                    HapticManager.shared.selectionChanged()
                                    settings.displayCurrency = currency
                                }
                            }
                        }
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

            Text("Display Currency")
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

private struct CurrencyOptionRow: View {
    let currency: Currency
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Card {
                HStack(spacing: DesignSystem.Spacing.md) {
                    Text(currency.symbol)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(.brandPrimary)
                        .rotationEffect(currency.isRotated ? .degrees(180) : .degrees(0))
                        .frame(width: 32, alignment: .center)

                    Text(currency.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textPrimary)

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.brandPrimary)
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }
}
