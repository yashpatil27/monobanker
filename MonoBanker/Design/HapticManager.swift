//
//  HapticManager.swift
//  MonoBanker
//

import UIKit

final class HapticManager {
    static let shared = HapticManager()
    private init() {}

    /// Global on/off flag — driven by AppSettings.hapticsEnabled.
    var isEnabled: Bool = true

    private let light = UIImpactFeedbackGenerator(style: .light)
    private let medium = UIImpactFeedbackGenerator(style: .medium)
    private let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    func lightImpact() { guard isEnabled else { return }; light.impactOccurred() }
    func mediumImpact() { guard isEnabled else { return }; medium.impactOccurred() }
    func heavyImpact() { guard isEnabled else { return }; heavy.impactOccurred() }
    func selectionChanged() { guard isEnabled else { return }; selection.selectionChanged() }
    func success() { guard isEnabled else { return }; notification.notificationOccurred(.success) }
    func warning() { guard isEnabled else { return }; notification.notificationOccurred(.warning) }
    func error() { guard isEnabled else { return }; notification.notificationOccurred(.error) }
}
