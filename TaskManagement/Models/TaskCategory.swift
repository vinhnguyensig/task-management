//
//  TaskCategory.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import Foundation
import SwiftUI

enum TaskCategory: String, CaseIterable, Codable {
    case work = "Work"
    case events = "Events"
    case learning = "Learning"
    case personal = "Personal"
    case shopping = "Shopping"
    case health = "Health & Fitness"
    case finances = "Finances"
    case home = "Home"
    case family = "Family"
    case travel = "Travel"
    case others = "Others"
    
    var color: Color {
        switch self {
        case .work: return .blue
        case .personal: return .green
        case .shopping: return .purple
        case .health: return .red
        case .finances: return .yellow
        case .home: return .brown
        case .family: return .pink
        case .learning: return .teal
        case .travel: return .cyan
        case .events: return .indigo
        case .others: return .orange
        }
    }
    
    var icon: String {
        switch self {
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .shopping: return "cart.fill"
        case .health: return "heart.fill"
        case .finances: return "creditcard.fill"
        case .home: return "house.fill"
        case .family: return "person.2.fill"
        case .learning: return "book.closed.fill"
        case .travel: return "airplane.departure"
        case .events: return "calendar"
        case .others: return "list.star"
        }
    }
}
