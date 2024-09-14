//
//  HapticManager.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 12/9/24.
//

import Foundation
import SwiftUI

class HapticManager {
    static let shared = HapticManager()

    private init() {}

    // Impact Feedback
    func triggerImpactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let impactFeedback = UIImpactFeedbackGenerator(style: style)
        impactFeedback.prepare()
        impactFeedback.impactOccurred()
    }

    // Notification Feedback
    func triggerNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType = .success) {
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.prepare()
        notificationFeedback.notificationOccurred(type)
    }

    // Selection Feedback
    func triggerSelectionFeedback() {
        let selectionFeedback = UISelectionFeedbackGenerator()
        selectionFeedback.prepare()
        selectionFeedback.selectionChanged()
    }
}
