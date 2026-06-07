//
//  BrandColors.swift
//  MonoBanker
//
//  Color tokens (cloned from BitTrade-iOS for consistent visual style).
//

import SwiftUI

extension Color {
    /// Brand color #ffd4d4 — Strike-inspired pink accent
    static let brandPrimary = Color(red: 1.0, green: 0.831, blue: 0.831)

    /// Primary text color (white)
    static let textPrimary = Color.white

    /// Secondary text color (light gray #bfbfbf)
    static let textSecondary = Color(red: 0.749, green: 0.749, blue: 0.749)

    /// Primary background (pure black)
    static let bgPrimary = Color.black

    /// Secondary background (cards) #2e2e2e
    static let bgSecondary = Color(red: 0.180, green: 0.180, blue: 0.180)

    /// Tertiary background (hover/highlight) #3e3e3e
    static let bgTertiary = Color(red: 0.243, green: 0.243, blue: 0.243)

    /// Success color (green) #4ade80
    static let success = Color(red: 0.290, green: 0.867, blue: 0.502)

    /// Error color (red) #f87171
    static let error = Color(red: 0.973, green: 0.443, blue: 0.443)
}
