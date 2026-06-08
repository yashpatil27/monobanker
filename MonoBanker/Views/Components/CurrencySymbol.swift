//
//  CurrencySymbol.swift
//  MonoBanker
//
//  Renders the user-selected currency symbol from AppSettings, applying a
//  180° rotation when the selected currency requires it (e.g. Inverted Won).
//  Inherits font/color from the surrounding context so it composes inside an
//  HStack alongside the digits Text.
//

import SwiftUI

struct CurrencySymbol: View {
    @Environment(AppSettings.self) private var settings

    var body: some View {
        Text(settings.displayCurrency.symbol)
            .rotationEffect(settings.displayCurrency.isRotated ? .degrees(180) : .degrees(0))
    }
}
