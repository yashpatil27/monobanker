//
//  GameView.swift
//  MonoBanker
//

import SwiftUI

struct GameView: View {
    @Bindable var session: GameSession
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

    /// Player rows switch from 2 to 3 columns once there are more than 6 players,
    /// so every card stays on screen without scrolling.
    private var columnCount: Int {
        session.players.count > 6 ? 3 : 2
    }

    private var playerRows: [[Participant]] {
        let c = columnCount
        let items = session.players.map { Participant.player($0.id) }
        return stride(from: 0, to: items.count, by: c).map {
            Array(items[$0..<min($0 + c, items.count)])
        }
    }

    private var totalRowCount: Int { 1 + playerRows.count }

    var body: some View {
        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                gridArea
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.md)

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
                onAddPlayer: {
                    showingMenu = false
                    showingAddPlayer = true
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
            .presentationDetents([.height(360)])
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
        .alert("Restart game?", isPresented: $showingRestartConfirm) {
            Button("Restart", role: .destructive) {
                HapticManager.shared.mediumImpact()
                session.restart()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Every balance returns to $\(session.startingBalance) and all transactions are cleared.")
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

            // Player row card widths share the full width.
            let playerCols = CGFloat(columnCount)
            let playerRowCardW = (availableW - spacing * (playerCols - 1)) / playerCols

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

                // Player rows: 2 or 3 columns depending on player count.
                ForEach(playerRows.indices, id: \.self) { rowIdx in
                    gridRow(
                        playerRows[rowIdx],
                        columns: columnCount,
                        cardSize: CGSize(width: playerRowCardW, height: rowH),
                        spacing: spacing
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }

    /// Top row: vertical stack of 3 buttons on the left, then Bank, then All.
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
            VStack(spacing: buttonSpacing) {
                sideButton(systemName: "line.3.horizontal", size: buttonSize) {
                    HapticManager.shared.lightImpact()
                    showingMenu = true
                }
                sideButton(systemName: "questionmark", size: buttonSize) {
                    HapticManager.shared.lightImpact()
                }
                sideButton(systemName: "ellipsis", size: buttonSize) {
                    HapticManager.shared.lightImpact()
                }
            }
            .frame(width: sideColumnW, height: rowH, alignment: .center)

            cardView(for: .bank, cardSize: CGSize(width: cardW, height: rowH))
                .frame(maxWidth: .infinity, minHeight: rowH, maxHeight: rowH)

            cardView(for: .all, cardSize: CGSize(width: cardW, height: rowH))
                .frame(maxWidth: .infinity, minHeight: rowH, maxHeight: rowH)
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

    /// One row of cards with trailing blank slots to keep column widths consistent.
    @ViewBuilder
    private func gridRow(_ items: [Participant], columns: Int, cardSize: CGSize, spacing: CGFloat) -> some View {
        HStack(spacing: spacing) {
            ForEach(items, id: \.self) { participant in
                cardView(for: participant, cardSize: cardSize)
                    .frame(maxWidth: .infinity, minHeight: cardSize.height, maxHeight: cardSize.height)
            }
            let blanks = columns - items.count
            if blanks > 0 {
                ForEach(0..<blanks, id: \.self) { _ in
                    Color.clear.frame(maxWidth: .infinity, minHeight: cardSize.height, maxHeight: cardSize.height)
                }
            }
        }
    }

    // MARK: - Card factory + drag/drop

    @ViewBuilder
    private func cardView(for participant: Participant, cardSize: CGSize) -> some View {
        let isTargeted = hoveredTarget == participant && draggingId != participant && draggingId != nil

        ParticipantCard(
            participant: participant,
            name: session.name(for: participant),
            balance: session.balance(of: participant),
            color: accentColor(for: participant),
            isDragging: false, // source card never animates; only the floating preview does
            isTargeted: isTargeted,
            isInactive: false
        )
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
                    handleDragChange(participant: participant, value: value)
                }
                .onEnded { value in
                    handleDragEnd(participant: participant, value: value)
                }
        )
    }

    // MARK: - Drag preview overlay

    @ViewBuilder
    private var floatingDragPreview: some View {
        if let dragged = draggingId,
           let loc = dragTouchLocation,
           let frame = cardFrames[dragged] {
            ParticipantCard(
                participant: dragged,
                name: session.name(for: dragged),
                balance: session.balance(of: dragged),
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
