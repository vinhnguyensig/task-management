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
    case personal = "Personal"
    case shopping = "Shopping"
    case health = "Health & Fitness"
    case finances = "Finances"
    case home = "Home"
    case family = "Family"
    case learning = "Learning"
    case travel = "Travel"
    case events = "Events"
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
    
    var icon: Image {
        switch self {
        case .work: return Image(systemName: "briefcase.fill")
        case .personal: return Image(systemName: "person.fill")
        case .shopping: return Image(systemName: "cart.fill")
        case .health: return Image(systemName: "heart.fill")
        case .finances: return Image(systemName: "creditcard.fill")
        case .home: return Image(systemName: "house.fill")
        case .family: return Image(systemName: "person.2.fill")
        case .learning: return Image(systemName: "book.closed.fill")
        case .travel: return Image(systemName: "airplane.departure")
        case .events: return Image(systemName: "calendar")
        case .others: return Image(systemName: "list.star")
        }
    }
}
