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
        let name = session.name(for: participant)
        let balance = session.balance(of: participant)
        let color: Color = {
            switch participant {
            case .bank: return .brandPrimary
            case .all:  return .white
            case .player(let id):
                return session.player(for: id)?.color.color ?? .brandPrimary
            }
        }()

        let isDragging = draggingId == participant
        let isTargeted = hoveredTarget == participant && draggingId != participant && draggingId != nil

        ParticipantCard(
            participant: participant,
            name: name,
            balance: balance,
            color: color,
            isDragging: isDragging,
            isTargeted: isTargeted,
            isInactive: false
        )
        .opacity(draggingId == participant ? 0.0 : 1.0) // hide original while dragging (preview shows)
        .draggable(ParticipantDragPayload(participant: participant)) {
            // Drag preview matches the actual rendered card size.
            ParticipantCard(
                participant: participant,
                name: name,
                balance: balance,
                color: color,
                isDragging: true,
                isTargeted: false,
                isInactive: false
            )
            .frame(width: cardSize.width, height: cardSize.height)
            .onAppear {
                HapticManager.shared.lightImpact()
                draggingId = participant
            }
            .onDisappear {
                draggingId = nil
                hoveredTarget = nil
            }
        }
        .dropDestination(for: ParticipantDragPayload.self) { items, _ in
            guard let payload = items.first else { return false }
            let payer = payload.participant
            let recipient = participant
            guard payer != recipient else { return false }
            // Bank cannot interact with All.
            if (payer.isBank && recipient.isAll) || (payer.isAll && recipient.isBank) {
                HapticManager.shared.warning()
                draggingId = nil
                hoveredTarget = nil
                return false
            }
            HapticManager.shared.heavyImpact()
            pendingTransaction = (from: payer, to: recipient)
            draggingId = nil
            hoveredTarget = nil
            return true
        } isTargeted: { targeted in
            // Don't highlight Bank when an All card is being dragged (or vice versa).
            let invalid = (draggingId?.isBank == true && participant.isAll)
                || (draggingId?.isAll == true && participant.isBank)
            if targeted && !invalid {
                hoveredTarget = participant
            } else if hoveredTarget == participant {
                hoveredTarget = nil
            }
        }
    }
}
