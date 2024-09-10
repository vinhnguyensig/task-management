//
//  TaskStatus.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import Foundation
import SwiftUI

enum TaskStatus: String, CaseIterable, Codable {
    case backlog = "Backlog"
    case pending = "Pending"
    case inProgress = "In Progress"
    case completed = "Completed"
    case inReview = "In Review"
    case done = "Done"
    case onHold = "On Hold"
    case canceled = "Canceled"
    
    // Color associated with each status for UI purposes
    var color: Color {
        switch self {
        case .backlog: return .gray
        case .pending: return .gray
        case .inProgress: return .blue
        case .completed: return .cyan
        case .done: return .green
        case .onHold: return .orange
        case .canceled: return .red
        case .inReview: return .purple
        }
    }
    
    // Icon associated with each status
    var icon: Image {
        switch self {
        case .backlog: return Image(systemName: "note")
        case .pending: return Image(systemName: "square")
        case .inProgress: return Image(systemName: "arrow.triangle.2.circlepath")
        case .completed: return Image(systemName: "circle.badge.checkmark")
        case .done: return Image(systemName: "checkmark.seal.fill")
        case .onHold: return Image(systemName: "pause.circle.fill")
        case .canceled: return Image(systemName: "xmark.square.fill")
        case .inReview: return Image(systemName: "questionmark.circle.fill")
        }
    }
}
