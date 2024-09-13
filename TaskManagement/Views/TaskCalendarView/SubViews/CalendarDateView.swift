//
//  CalendarDateView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 12/9/24.
//

import SwiftUI

struct CalendarDateView: View {
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void

    private var dayOfWeek: String {
        date.formatted(.dateTime.weekday(.abbreviated))
    }

    private var dayOfMonth: String {
        date.formatted(.dateTime.day())
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(dayOfWeek)
                .font(.caption)
                .foregroundColor(isSelected ? .white : .secondary)
            Text(dayOfMonth)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .primary)
        }
        .padding(12)
        .frame(width: 60, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.accentColor : Color(.systemBackground))
        )
        .shadow(color: isSelected ? Color.accentColor.opacity(0.1) : Color.black.opacity(0.1), radius: 4)
        .onTapGesture(perform: onTap)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(isSelected ? .isSelected : .isStaticText)
    }
}
