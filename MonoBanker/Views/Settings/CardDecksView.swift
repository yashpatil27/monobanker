//
//  CardDecksView.swift
//  MonoBanker
//
//  Sub-page under Game Preferences for editing the two card decks. Lets
//  the user rename each deck and add/remove cards. All edits flow
//  directly into CardDecksStore via SwiftUI bindings.
//

import SwiftUI
import UniformTypeIdentifiers

struct CardDecksView: View {
    @Environment(CardDecksStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var store = store

        ZStack {
            Color.bgPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxl) {
                        Text("Add your own cards to each deck. Tap a deck button in the game to draw one at random. Decks and cards stay on your device.")
                            .font(.system(size: 12))
                            .foregroundColor(.textSecondary)

                        ForEach($store.decks) { $deck in
                            DeckEditorSection(deck: $deck)
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

            Text("Card Decks")
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

// MARK: - Deck editor

private struct DeckEditorSection: View {
    @Binding var deck: CardDeck
    @State private var newCard: String = ""
    @FocusState private var newCardFocused: Bool
    @State private var showingImporter = false
    @State private var showingURLImport = false
    @State private var urlText: String = ""
    @State private var isFetching = false
    @State private var importError: String?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            // Section header with card count + import action.
            HStack {
                Text("DECK")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .kerning(1.2)
                Spacer()
                Text("\(deck.cards.count) CARDS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.textSecondary)
                    .kerning(1.2)
                Button {
                    HapticManager.shared.lightImpact()
                    urlText = ""
                    showingURLImport = true
                } label: {
                    importPill(icon: "link", text: "FROM URL")
                }
                .buttonStyle(.plain)
                .disabled(isFetching)

                Button {
                    HapticManager.shared.lightImpact()
                    showingImporter = true
                } label: {
                    importPill(icon: "square.and.arrow.down", text: "FROM FILE")
                }
                .buttonStyle(.plain)
                .disabled(isFetching)
            }

            // Editable deck name.
            Card {
                HStack(spacing: DesignSystem.Spacing.md) {
                    Image(systemName: "rectangle.stack")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textSecondary)
                        .frame(width: 24)
                    TextField("Deck name", text: $deck.name)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.textPrimary)
                        .tint(.brandPrimary)
                        .submitLabel(.done)
                }
            }

            // Existing cards.
            ForEach(Array(deck.cards.enumerated()), id: \.offset) { index, text in
                Card {
                    HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                        Text(text)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                        Button {
                            HapticManager.shared.lightImpact()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                _ = deck.cards.remove(at: index)
                            }
                        } label: {
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

            // Add a new card.
            Card {
                HStack(alignment: .center, spacing: DesignSystem.Spacing.md) {
                    TextField("New card text", text: $newCard, axis: .vertical)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.textPrimary)
                        .tint(.brandPrimary)
                        .focused($newCardFocused)
                        .lineLimit(1...4)
                        .submitLabel(.done)
                        .onSubmit(addCard)
                    Button(action: addCard) {
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
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.json]
        ) { result in
            handleImport(result)
        }
        .alert("Import from URL", isPresented: $showingURLImport) {
            TextField("https://example.com/deck.json", text: $urlText)
                .textInputAutocapitalization(.never)
                .keyboardType(.URL)
                .autocorrectionDisabled()
            Button("Import") {
                Task { await importFromURL(urlText) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Paste a link to a JSON deck file. GitHub blob links are auto-converted to raw URLs.")
        }
        .alert(
            "Import failed",
            isPresented: Binding(
                get: { importError != nil },
                set: { if !$0 { importError = nil } }
            )
        ) {
            Button("OK", role: .cancel) { importError = nil }
        } message: {
            Text(importError ?? "")
        }
    }

    // MARK: - Pill UI

    private func importPill(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))
            Text(text)
                .font(.system(size: 10, weight: .semibold))
                .kerning(1.2)
        }
        .foregroundColor(.brandPrimary)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color.brandPrimary.opacity(0.15))
                .overlay(
                    Capsule()
                        .stroke(Color.brandPrimary.opacity(0.4), lineWidth: 1)
                )
        )
    }

    private var canAdd: Bool {
        !newCard.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func addCard() {
        let trimmed = newCard.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        HapticManager.shared.lightImpact()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            deck.cards.append(trimmed)
            newCard = ""
        }
        newCardFocused = true
    }

    /// Reads the selected JSON file, decodes a single deck, and replaces
    /// this deck's name + cards + draw pile.
    private func handleImport(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            guard url.startAccessingSecurityScopedResource() else {
                importError = "Couldn’t access the file."
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            do {
                let data = try Data(contentsOf: url)
                let imported = try JSONDecoder().decode(ImportedDeck.self, from: data)
                applyImported(imported)
            } catch {
                importError = "Couldn’t read deck: \(error.localizedDescription)"
            }
        case .failure(let error):
            importError = error.localizedDescription
        }
    }

    /// Fetches JSON from a user-pasted URL, decodes it, and applies it to
    /// the deck. GitHub `https://github.com/.../blob/.../file.json` links
    /// are auto-rewritten to `raw.githubusercontent.com` so users can
    /// paste straight from the browser URL bar.
    @MainActor
    private func importFromURL(_ raw: String) async {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            importError = "Please paste a URL."
            return
        }
        guard let url = URL(string: trimmed),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else {
            importError = "That doesn’t look like a valid http(s) URL."
            return
        }
        let target = normalizedGitHubRawURL(url)
        isFetching = true
        defer { isFetching = false }
        do {
            let (data, response) = try await URLSession.shared.data(from: target)
            if let http = response as? HTTPURLResponse,
               !(200..<300).contains(http.statusCode) {
                importError = "Server returned HTTP \(http.statusCode)."
                return
            }
            let imported = try JSONDecoder().decode(ImportedDeck.self, from: data)
            applyImported(imported)
        } catch {
            importError = "Couldn’t fetch deck: \(error.localizedDescription)"
        }
    }

    /// Common post-decode handler: trims, applies, resets the draw pile.
    private func applyImported(_ imported: ImportedDeck) {
        let trimmedName = imported.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedCards = imported.cards
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        HapticManager.shared.success()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if !trimmedName.isEmpty {
                deck.name = trimmedName
            }
            deck.cards = cleanedCards
            deck.drawPile = []  // force reshuffle on next draw
        }
    }

    /// Rewrites `https://github.com/<user>/<repo>/blob/<branch>/<path>` to
    /// `https://raw.githubusercontent.com/<user>/<repo>/<branch>/<path>`.
    /// Returns the original URL untouched if it isn't a GitHub blob link.
    private func normalizedGitHubRawURL(_ url: URL) -> URL {
        guard url.host == "github.com",
              let blobRange = url.path.range(of: "/blob/") else { return url }
        let newPath = url.path.replacingCharacters(in: blobRange, with: "/")
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.host = "raw.githubusercontent.com"
        components?.path = newPath
        return components?.url ?? url
    }
}

/// Wire-format for an imported deck. `name` is the new deck name to apply;
/// `cards` is the new card list. Both required.
private struct ImportedDeck: Decodable {
    let name: String
    let cards: [String]
}
