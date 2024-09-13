//
//  DateSectionHeaderView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 13/9/24.
//

import SwiftUI

struct DateSectionHeaderView: View {
    let date: Date

    var body: some View {
        HStack(alignment: .bottom) {
            Text(Utils.formattedDate(date))
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.vertical, 8)
                .padding(.leading)
            Spacer()
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 2)
    }
}
