//
//  TaskProgress.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 13/9/24.
//

import Foundation
import SwiftUI

enum TaskProgress {
    static func getProgressMessage(progress: Double) -> String {
        switch progress {
        case 0.0:
            return "Let's get started!"
        case 0.0..<0.3:
            return "Good start! Keep going!"
        case 0.3..<0.6:
            return "You're making progress!"
        case 0.6..<0.8:
            return "You're more than halfway there!"
        case 0.8..<1.0:
            return "Almost done!"
        case 1.0:
            return "Great job! You've completed everything for today!"
        default:
            return "Keep pushing forward!"
        }
    }
    
    static func getProgressColor(progress: Double) -> Color {
        switch progress {
        case 0.0:
            return .gray
        case 0.0..<0.3:
            return .yellow
        case 0.3..<0.6:
            return .orange
        case 0.6..<0.8:
            return .accentColor
        case 0.8..<1.0:
            return .purple
        case 1.0:
            return .green
        default:
            return .gray
        }
    }
}
