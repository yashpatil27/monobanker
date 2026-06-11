//
//  InvertedCurrencyText.swift
//  MonoBanker
//
//  Renders free-form text (Chance/Community Chest card bodies, held-card
//  rows) with every recognised currency glyph swapped for the user's
//  selected display currency. When the selected currency is the
//  Inverted Won variant, individual ₩ glyphs are rotated 180° in place
//  via a custom `TextRenderer` so the rest of the paragraph continues
//  to flow as native `Text` — selection, accessibility, line wrapping,
//  and the inherited font are all preserved.
//
//  Requires iOS 18 (TextRenderer / TextAttribute APIs).
//

import SwiftUI

/// Marker attribute attached to each substituted currency-glyph `Text`
/// run so `InvertedCurrencyRenderer` knows which runs to rotate.
private struct InvertedCurrencySymbolAttribute: TextAttribute {}

/// Rotates every `Text.Layout.Run` carrying `InvertedCurrencySymbolAttribute`
/// 180° around its own typographic centre. All other runs draw normally.
private struct InvertedCurrencyRenderer: TextRenderer {
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        for line in layout {
            for run in line {
                if run[InvertedCurrencySymbolAttribute.self] != nil {
                    let rect = run.typographicBounds.rect
                    let center = CGPoint(x: rect.midX, y: rect.midY)
                    var copy = ctx
                    copy.translateBy(x: center.x, y: center.y)
                    copy.rotate(by: .degrees(180))
                    copy.translateBy(x: -center.x, y: -center.y)
                    copy.draw(run)
                } else {
                    ctx.draw(run)
                }
            }
        }
    }
}

/// Card-body text wrapper. Swaps recognised currency glyphs for the
/// user's selected `displayCurrency` symbol; for the Inverted Won
/// variant, every substituted glyph is tagged with a custom
/// `TextAttribute` so `InvertedCurrencyRenderer` can rotate it in
/// place. For all other currencies this resolves to a single plain
/// `Text` with no overhead.
struct InvertedCurrencyText: View {
    @Environment(AppSettings.self) private var settings
    let text: String

    var body: some View {
        let currency = settings.displayCurrency
        if currency.isRotated, text.contains(where: Currency.knownSymbols.contains) {
            buildSegmentedText(symbol: currency.symbol)
                .textRenderer(InvertedCurrencyRenderer())
        } else {
            Text(currency.rewritingSymbols(in: text))
        }
    }

    /// Concatenates plain spans of text with single-glyph attributed
    /// runs so each currency symbol ends up as its own renderer run.
    private func buildSegmentedText(symbol: String) -> Text {
        var result = Text(verbatim: "")
        var buffer = ""

        func flushBuffer() {
            guard !buffer.isEmpty else { return }
            result = result + Text(verbatim: buffer)
            buffer.removeAll(keepingCapacity: true)
        }

        for char in text {
            if Currency.knownSymbols.contains(char) {
                flushBuffer()
                result = result
                    + Text(verbatim: symbol)
                        .customAttribute(InvertedCurrencySymbolAttribute())
            } else {
                buffer.append(char)
            }
        }
        flushBuffer()
        return result
    }
}
