//
//  DesignSystem.swift
//  MonoBanker
//
//  Centralized spacing/radius/opacity tokens (cloned from BitTrade-iOS).
//

import SwiftUI

enum DesignSystem {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
        static let xxxl: CGFloat = 32
    }

    enum CornerRadius {
        static let sm: CGFloat = 6
        static let md: CGFloat = 8
        static let lg: CGFloat = 12
        static let xl: CGFloat = 16
        static let xxl: CGFloat = 20
    }

    enum Opacity {
        static let subtle: Double = 0.1
        static let light: Double = 0.2
        static let medium: Double = 0.3
        static let visible: Double = 0.5
        static let strong: Double = 0.8
    }

    enum IconSize {
        static let sm: CGFloat = 32
        static let md: CGFloat = 40
        static let lg: CGFloat = 48
        static let xl: CGFloat = 64
    }

    enum ButtonHeight {
        static let sm: CGFloat = 36
        static let md: CGFloat = 44
        static let lg: CGFloat = 52
    }

    enum BorderWidth {
        static let thin: CGFloat = 1
        static let medium: CGFloat = 2
    }
}
