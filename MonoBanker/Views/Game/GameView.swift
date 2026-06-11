//
//  GameView.swift
//  MonoBanker
//

import SwiftUI

struct GameView: View {
    @Bindable var session: GameSession
    @Environment(AppSettings.self) private var settings
    @Environment(CardDecksStore.self) private var cardDecksStore
    let onEndGame: () -> Void

    @State private var draggingId: Participant?
    @State private var hoveredTarget: Participant?
    @State private var dragTouchLocation: CGPoint?
    @State private var cardFrames: [Participant: CGRect] = [:]
    @State private var pendingTransaction: (from: Participant, to: Participant)?
    @State private var showingHistory = false
    @State private var showingMenu = false
    @State private var showingEndConfirm = false
    @State private var showingRestartConfirm = false
    @State private var showingAddPlayer = false
    @State private var showingSettings = false

    // Rearrange mode
    @State private var isRearranging = false
    @State private var reorderDraggedID: UUID?
    @State private var reorderTouchLocation: CGPoint?
    /// Live preview of the reordered player list while a reorder drag is in flight.
    /// `nil` outside of an active reorder — fall back to `session.players` for rendering.
    @State private var reorderedPlayers: [Player]?

    // Dice card state (only used when settings.diceEnabled is true).
    @State private var diceLeft: Int = 1
    @State private var diceRight: Int = 1
    @State private var diceRollID: Int = 0

    // Card-deck draw state (only used when settings.cardDecksEnabled is true).
    @State private var drawnCard: (deckName: String, text: String)?

    /// During a reorder drag, render from the in-flight preview order instead of session.
    private var effectivePlayers: [Player] {
        reorderedPlayers ?? session.players
    }

    /// Player rows switch from 2 to 3 columns once there are more than 6 players,
    /// so every card stays on screen without scrolling.
    private var columnCount: Int {
        effectivePlayers.count > 6 ? 3 : 2
    }

    private var playerRowCount: Int {
        guard !effectivePlayers.isEmpty else { return 0 }
        return (effectivePlayers.count + columnCount - 1) / columnCount
    }

    private var totalRowCount: Int { 1 + playerRowCount }

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                gridArea
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.md)

                if settings.cardDecksEnabled {
                    CardDecksRow(decks: cardDecksStore.decks) { deck in
                        handleDeckTap(deck)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.sm)
                }

                HistoryStrip(session: session) { showingHistory = true }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.lg)
            }

            // Floating drag preview — follows the finger and is drawn above the grid.
            floatingDragPreview
        }
        .coordinateSpace(name: GameView.gameViewSpace)
        .onPreferenceChange(CardFramePreferenceKey.self) { frames in
            cardFrames = frames
        }
        .fullScreenCover(isPresented: Binding(
            get: { pendingTransaction != nil },
            set: { if !$0 { pendingTransaction = nil } }
        )) {
            if let pending = pendingTransaction {
                TransactionOverlay(
                    session: session,
                    payer: pending.from,
                    recipient: pending.to,
                    onCancel: {
                        pendingTransaction = nil
                    },
                    onConfirm: { totalAmount in
                        session.pay(from: pending.from, to: pending.to, totalAmount: totalAmount)
                        HapticManager.shared.success()
                        pendingTransaction = nil
                    }
                )
                .presentationBackground(.black.opacity(0.92))
            }
        }
        .sheet(isPresented: $showingHistory) {
            HistorySheet(session: session)
                .presentationDetents([.medium, .large])
                .presentationBackground(.black)
        }
        .sheet(isPresented: $showingMenu) {
            MenuSheet(
                onShowHistory: {
                    showingMenu = false
                    showingHistory = true
                },
                onRestart: {
                    showingMenu = false
                    showingRestartConfirm = true
                },
                onEndGame: {
                    showingMenu = false
                    showingEndConfirm = true
                }
            )
            .presentationDetents([.height(300)])
            .presentationBackground(.black)
        }
        .sheet(isPresented: $showingAddPlayer) {
            AddPlayerSheet(
                usedColors: Set(session.players.map(\.color))
            ) { name, color in
                HapticManager.shared.success()
                session.addPlayer(name: name, color: color)
            }
            .presentationDetents([.height(320)])
            .presentationBackground(.black)
        }
        .fullScreenCover(isPresented: $showingSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: Binding(
            get: { drawnCard != nil },
            set: { if !$0 { drawnCard = nil } }
        )) {
            if let card = drawnCard {
                CardDrawSheet(
                    deckName: card.deckName,
                    cardText: card.text,
                    onDismiss: { drawnCard = nil }
                )
                .presentationBackground(.black.opacity(0.92))
            }
        }
        .alert("Restart game?", isPresented: $showingRestartConfirm) {
            Button("Restart", role: .destructive) {
                HapticManager.shared.mediumImpact()
                session.restart()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Every balance returns to \(settings.format(session.startingBalance)) and all transactions are cleared.")
        }
        .alert("End this game?", isPresented: $showingEndConfirm) {
            Button("End Game", role: .destructive) {
                HapticManager.shared.mediumImpact()
                onEndGame()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The session will be wiped.")
        }
    }

    // MARK: - Grid

    private var gridArea: some View {
        GeometryReader { proxy in
            let spacing = DesignSystem.Spacing.md
            let count = CGFloat(totalRowCount)
            let availableH = proxy.size.height
            let availableW = proxy.size.width
            let totalSpacing = max(0, count - 1) * spacing
            let idealRow = count > 0 ? (availableH - totalSpacing) / count : availableH
            // Clamp so cards don't look comically tall with few players and stay readable when many.
            let rowH = min(140, max(70, idealRow))

            // Side-button column (Menu + 2 dummies) sits to the left of Bank + All on the top row.
            let buttonSpacing = DesignSystem.Spacing.sm
            let buttonSize = min(44, max(28, (rowH - 2 * buttonSpacing) / 3))
            let sideColumnW = buttonSize

            // Top row card widths share the remaining space after the button column.
            let topRowCardW = (availableW - sideColumnW - spacing * 2) / 2

            VStack(spacing: spacing) {
                // Top row: side buttons + Bank + All.
                topGridRow(
                    rowH: rowH,
                    cardW: topRowCardW,
                    sideColumnW: sideColumnW,
                    buttonSize: buttonSize,
                    spacing: spacing,
                    buttonSpacing: buttonSpacing
                )

                // Player cards in a single LazyVGrid so each card keeps a stable view
                // identity (and a stable DragGesture) as the array reorders during a rearrange drag.
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columnCount),
                    alignment: .leading,
                    spacing: spacing
                ) {
                    ForEach(effectivePlayers) { player in
                        cardView(for: .player(player.id))
                            .frame(maxWidth: .infinity, minHeight: rowH, maxHeight: rowH)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    /// Top row: vertical stack of 3 buttons on the left, then Bank, then All.
    /// In rearrange mode the side column collapses to a single Done button.
    /// When the dice card is enabled, Bank and All stack vertically into a single
    /// half-height column and the dice card occupies the third column.
    @ViewBuilder
    private func topGridRow(
        rowH: CGFloat,
        cardW: CGFloat,
        sideColumnW: CGFloat,
        buttonSize: CGFloat,
        spacing: CGFloat,
        buttonSpacing: CGFloat
    ) -> some View {
        HStack(spacing: spacing) {
            sideColumn(buttonSize: buttonSize, buttonSpacing: buttonSpacing)
                .frame(width: sideColumnW, height: rowH, alignment: .center)

            if settings.diceEnabled {
                // Bank stays full-size on its own.
                cardView(for: .bank)
                    .frame(maxWidth: .infinity, minHeight: rowH, maxHeight: rowH)

                // All + Dice share a half-height stacked column.
                VStack(spacing: DesignSystem.Spacing.sm) {
                    cardView(for: .all, compact: true)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    DiceCard(left: diceLeft, right: diceRight, rollID: diceRollID, onRoll: rollDice)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, minHeight: rowH, maxHeight: rowH)
            } else {
                cardView(for: .bank)
                    .frame(maxWidth: .infinity, minHeight: rowH, maxHeight: rowH)

                cardView(for: .all)
                    .frame(maxWidth: .infinity, minHeight: rowH, maxHeight: rowH)
            }
        }
    }

    private func rollDice() {
        HapticManager.shared.mediumImpact()
        diceRollID &+= 1   // ensure DiceCard re-triggers even when faces repeat
        let pair = DiceRoller.rollPair()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            diceLeft = pair.left
            diceRight = pair.right
        }
    }

    /// Tap handler for a card-deck button: draws a card without
    /// replacement and presents the reveal sheet, or routes the user to
    /// Settings if the deck is empty.
    private func handleDeckTap(_ deck: CardDeck) {
        if let text = cardDecksStore.draw(fromDeckID: deck.id) {
            HapticManager.shared.success()
            drawnCard = (deckName: deck.name, text: text)
        } else {
            HapticManager.shared.warning()
            showingSettings = true
        }
    }

    @ViewBuilder
    private func sideColumn(buttonSize: CGFloat, buttonSpacing: CGFloat) -> some View {
        if isRearranging {
            VStack(spacing: buttonSpacing) {
                Spacer(minLength: 0)
                Button {
                    HapticManager.shared.mediumImpact()
                    exitRearrangeMode()
                } label: {
                    IconContainer(
                        systemName: "checkmark",
                        tint: .brandPrimary,
                        backgroundColor: Color.brandPrimary.opacity(0.18),
                        size: buttonSize,
                        iconSize: buttonSize * 0.42,
                        cornerRadius: DesignSystem.CornerRadius.md
                    )
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))

                sideButton(systemName: "person.badge.plus", size: buttonSize) {
                    HapticManager.shared.lightImpact()
                    showingAddPlayer = true
                }
                .transition(.scale.combined(with: .opacity))

                Spacer(minLength: 0)
            }
        } else {
            VStack(spacing: buttonSpacing) {
                sideButton(systemName: "line.3.horizontal", size: buttonSize) {
                    HapticManager.shared.lightImpact()
                    showingMenu = true
                }
                sideButton(systemName: "square.grid.2x2", size: buttonSize) {
                    enterRearrangeMode()
                }
                sideButton(systemName: "gearshape.fill", size: buttonSize) {
                    HapticManager.shared.lightImpact()
                    showingSettings = true
                }
            }
            .transition(.opacity)
        }
    }

    @ViewBuilder
    private func sideButton(systemName: String, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            IconContainer(
                systemName: systemName,
                tint: .textPrimary,
                backgroundColor: Color.gray.opacity(0.15),
                size: size,
                iconSize: size * 0.42,
                cornerRadius: DesignSystem.CornerRadius.md
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Card factory + drag/drop

    @ViewBuilder
    private func cardView(for participant: Participant, compact: Bool = false) -> some View {
        let isTargeted = hoveredTarget == participant && draggingId != participant && draggingId != nil
        let wobble = isRearranging && participantIsPlayer(participant)
        let removable = wobble
        let beingReordered = isReorderingParticipant(participant)

        ParticipantCard(
            participant: participant,
            name: session.name(for: participant),
            balance: session.balance(of: participant),
            lastChange: lastChange(for: participant),
            color: accentColor(for: participant),
            isDragging: false, // source card never animates; only the floating preview does
            isTargeted: isTargeted,
            isInactive: false,
            isWobbling: wobble,
            showRemove: removable,
            onRemove: removable ? { removePlayer(participant) } : nil,
            isCompact: compact
        )
        .opacity(beingReordered ? 0.0 : 1.0)
        .background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: CardFramePreferenceKey.self,
                    value: [participant: geo.frame(in: .named(GameView.gameViewSpace))]
                )
            }
        )
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0, coordinateSpace: .named(GameView.gameViewSpace))
                .onChanged { value in
                    if isRearranging {
                        handleRearrangeChange(participant: participant, value: value)
                    } else {
                        handleDragChange(participant: participant, value: value)
                    }
                }
                .onEnded { value in
                    if isRearranging {
                        handleRearrangeEnd(participant: participant, value: value)
                    } else {
                        handleDragEnd(participant: participant, value: value)
                    }
                }
        )
    }

    // MARK: - Drag preview overlay

    @ViewBuilder
    private var floatingDragPreview: some View {
        if let reorderID = reorderDraggedID,
           let loc = reorderTouchLocation,
           let player = effectivePlayers.first(where: { $0.id == reorderID }),
           let frame = cardFrames[.player(reorderID)] {
            // Reorder drag preview.
            ParticipantCard(
                participant: .player(reorderID),
                name: player.name,
                balance: player.balance,
                lastChange: session.lastDelta(for: reorderID),
                color: player.color.color,
                isDragging: true,
                isTargeted: false,
                isInactive: false
            )
            .frame(width: frame.width, height: frame.height)
            .shadow(color: Color.brandPrimary.opacity(0.45), radius: 22, y: 10)
            .position(loc)
            .allowsHitTesting(false)
        } else if let dragged = draggingId,
                  let loc = dragTouchLocation,
                  let frame = cardFrames[dragged] {
            // Pay drag preview.
            ParticipantCard(
                participant: dragged,
                name: session.name(for: dragged),
                balance: session.balance(of: dragged),
                lastChange: lastChange(for: dragged),
                color: accentColor(for: dragged),
                isDragging: true,
                isTargeted: false,
                isInactive: false
            )
            .frame(width: frame.width, height: frame.height)
            .shadow(color: Color.brandPrimary.opacity(0.35), radius: 18, y: 8)
            .position(loc)
            .allowsHitTesting(false)
            .transition(.opacity)
        }
    }

    // MARK: - Drag gesture handlers

    private func handleDragChange(participant: Participant, value: DragGesture.Value) {
        // Only commit the drag once the finger has moved — lets pure taps stay no-ops.
        let movedEnough = abs(value.translation.width) > 1 || abs(value.translation.height) > 1

        if draggingId == nil {
            guard movedEnough else { return }
            HapticManager.shared.lightImpact()
            draggingId = participant
        }

        dragTouchLocation = value.location

        let target = hitTest(value.location)
        if let target, target != participant, !isInvalidPair(payer: participant, recipient: target) {
            hoveredTarget = target
        } else if hoveredTarget != nil {
            hoveredTarget = nil
        }
    }

    private func handleDragEnd(participant: Participant, value: DragGesture.Value) {
        defer {
            draggingId = nil
            hoveredTarget = nil
            dragTouchLocation = nil
        }

        // No drag was ever committed (finger never moved enough) — silent no-op.
        guard draggingId != nil else { return }

        let dropTarget = hitTest(value.location)

        guard let target = dropTarget, target != participant else {
            // Released on the dragged card itself or in empty space — silent cancel.
            return
        }

        if isInvalidPair(payer: participant, recipient: target) {
            HapticManager.shared.warning()
            return
        }

        HapticManager.shared.heavyImpact()
        pendingTransaction = (from: participant, to: target)
    }

    private func hitTest(_ location: CGPoint) -> Participant? {
        for (participant, frame) in cardFrames where frame.contains(location) {
            return participant
        }
        return nil
    }

    private func isInvalidPair(payer: Participant, recipient: Participant) -> Bool {
        (payer.isBank && recipient.isAll) || (payer.isAll && recipient.isBank)
    }

    private func accentColor(for participant: Participant) -> Color {
        switch participant {
        case .bank: return .brandPrimary
        case .all:  return .white
        case .player(let id):
            return session.player(for: id)?.color.color ?? .brandPrimary
        }
    }

    /// The signed change to a player's balance from their most recent transaction.
    /// Returns nil for Bank, All, or players who haven't transacted yet.
    private func lastChange(for participant: Participant) -> Int? {
        if case .player(let id) = participant {
            return session.lastDelta(for: id)
        }
        return nil
    }

    // MARK: - Rearrange mode

    private func participantIsPlayer(_ participant: Participant) -> Bool {
        if case .player = participant { return true }
        return false
    }

    private func isReorderingParticipant(_ participant: Participant) -> Bool {
        guard let id = reorderDraggedID, case .player(let pid) = participant else { return false }
        return id == pid
    }

    private func enterRearrangeMode() {
        HapticManager.shared.mediumImpact()
        withAnimation(.easeInOut(duration: 0.2)) {
            isRearranging = true
        }
    }

    private func exitRearrangeMode() {
        // Clean up any in-flight reorder state and commit final order if needed.
        if let final = reorderedPlayers {
            session.reorderPlayers(final)
        }
        reorderDraggedID = nil
        reorderTouchLocation = nil
        reorderedPlayers = nil
        withAnimation(.easeInOut(duration: 0.2)) {
            isRearranging = false
        }
    }

    private func removePlayer(_ participant: Participant) {
        guard case .player(let id) = participant else { return }
        HapticManager.shared.warning()
        withAnimation(.easeInOut(duration: 0.25)) {
            session.removePlayer(id: id)
        }
    }

    private func handleRearrangeChange(participant: Participant, value: DragGesture.Value) {
        // Only player cards participate in reorder.
        guard case .player(let draggedID) = participant else { return }

        let movedEnough = abs(value.translation.width) > 1 || abs(value.translation.height) > 1

        if reorderDraggedID == nil {
            guard movedEnough else { return }
            HapticManager.shared.lightImpact()
            reorderDraggedID = draggedID
            reorderedPlayers = session.players
        }

        reorderTouchLocation = value.location

        // Hit-test for the player we're hovering over.
        guard let target = hitTest(value.location),
              case .player(let targetID) = target,
              targetID != draggedID,
              var current = reorderedPlayers,
              let currentIdx = current.firstIndex(where: { $0.id == draggedID }),
              let targetIdx = current.firstIndex(where: { $0.id == targetID }),
              currentIdx != targetIdx
        else { return }

        let p = current.remove(at: currentIdx)
        current.insert(p, at: targetIdx)
        HapticManager.shared.selectionChanged()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            reorderedPlayers = current
        }
    }

    private func handleRearrangeEnd(participant: Participant, value: DragGesture.Value) {
        defer {
            reorderDraggedID = nil
            reorderTouchLocation = nil
            reorderedPlayers = nil
        }

        // Drag never committed (e.g. just a tap on a wobbling card) — nothing to do.
        guard reorderDraggedID != nil, let final = reorderedPlayers else { return }

        session.reorderPlayers(final)
    }
}

// MARK: - Coordinate space + frame harvesting

private extension GameView {
    static let gameViewSpace = "gameView"
}

private struct CardFramePreferenceKey: PreferenceKey {
    static var defaultValue: [Participant: CGRect] = [:]
    static func reduce(value: inout [Participant: CGRect],
                       nextValue: () -> [Participant: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}
