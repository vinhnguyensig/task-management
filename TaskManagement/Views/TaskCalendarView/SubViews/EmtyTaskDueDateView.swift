//
//  EmtyTaskDueDateView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 13/9/24.
//

import SwiftUI

struct EmtyTaskDueDateView: View {
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: "calendar.badge.exclamationmark")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.gray)
            Text("No tasks for the selected date")
                .foregroundColor(.gray)
                .font(.headline)
                .padding()
            Spacer()
        }
    }
}
