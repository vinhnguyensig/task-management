//
//  TaskPriority.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import Foundation
import SwiftUI

enum TaskPriority: String, CaseIterable, Codable {
    case urgent = "Urgent"
    case high = "High"
    case medium = "Medium"
    case low = "Low"
    
    var color: Color {
        switch self {
        case .urgent: return .red
        case .high: return .orange
        case .medium: return .yellow
        case .low: return .green
        }
    }
    
    var icon: Image {
        switch self {
        case .urgent: return Image(systemName: "exclamationmark.octagon.fill")
        case .high: return Image(systemName: "exclamationmark.triangle.fill")
        case .medium: return Image(systemName: "exclamationmark.circle.fill")
        case .low: return Image(systemName: "checkmark.circle.fill")
        }
    }
}
