//
//  HapticManager.swift
//  MonoBanker
//

import UIKit

final class HapticManager {
    static let shared = HapticManager()
    private init() {}

    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    func lightImpact() { light.impactOccurred() }
    func mediumImpact() { medium.impactOccurred() }
    func heavyImpact() { heavy.impactOccurred() }
    func selectionChanged() { selection.selectionChanged() }
    func success() { notification.notificationOccurred(.success) }
    func warning() { notification.notificationOccurred(.warning) }
    func error() { notification.notificationOccurred(.error) }
}
