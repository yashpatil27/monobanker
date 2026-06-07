//
//  PlayerColor.swift
//  MonoBanker
//
//  Preset hues for player identity. Tuned for visibility on a black background.
//

import SwiftUI

enum PlayerColor: String, CaseIterable, Codable, Hashable, Identifiable {
    case red, orange, amber, lime, teal, sky, indigo, magenta

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .red:     return Color(red: 0.96, green: 0.45, blue: 0.45) // soft red
        case .orange:  return Color(red: 0.98, green: 0.62, blue: 0.38) // muted orange
        case .amber:   return Color(red: 0.98, green: 0.81, blue: 0.40) // warm amber
        case .lime:    return Color(red: 0.66, green: 0.87, blue: 0.45) // soft lime
        case .teal:    return Color(red: 0.40, green: 0.82, blue: 0.78) // teal
        case .sky:     return Color(red: 0.45, green: 0.71, blue: 0.96) // sky blue
        case .indigo:  return Color(red: 0.62, green: 0.55, blue: 0.95) // muted indigo
        case .magenta: return Color(red: 0.95, green: 0.55, blue: 0.85) // soft magenta
        }
    }
}
