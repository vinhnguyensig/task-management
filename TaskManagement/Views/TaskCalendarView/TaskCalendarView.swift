//
//  TaskCalendarView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 10/9/24.
//

import SwiftUI

struct TaskCalendarView: View {
    @State var selectedDate = Date()
    var body: some View {
        VStack {
            DueDatePicker(selectedDate: $selectedDate)
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
    }
}

#Preview {
    TaskCalendarView()
}
