//
//  DueDatePickerView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 11/9/24.
//

import SwiftUI

struct DueDatePickerView: View {
    @StateObject var viewModel = TaskCalendarViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var selectedDate: Date
    @State private var selectedTime: Date? = nil
    @State private var isExpanded: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button(action: {
                            selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
                        }) {
                            Label("Tomorrow", systemImage: "sun.max.fill")
                                .foregroundColor(.blue)
                                .padding(.horizontal)
                        }
                        Spacer()
                        Button(action: {
                            selectedDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
                        }) {
                            Label("Next Week", systemImage: "arrow.right.circle.fill")
                                .foregroundColor(.blue)
                                .padding(.horizontal)
                        }
                       
                    }
                }
                .padding()
                
                Divider()
                
                // Calendar View
                DueDateCalendarView(viewModel: viewModel, selectedDate: $selectedDate, isExpanded: $isExpanded)

                Divider()
                
                // Time Picker
                DatePicker("Select Time", selection: Binding(
                    get: {
                        selectedTime ?? Date()
                    },
                    set: { newValue in
                        selectedTime = newValue
                    }
                ), displayedComponents: .hourAndMinute)
                .datePickerStyle(.compact)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Set Due Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrowshape.down.circle")
                            .foregroundColor(.gray)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        if let selectedTime = selectedTime {
                                    // Combine the selected date and time
                                    let calendar = Calendar.current
                                    let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
                                    selectedDate = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                                                 minute: timeComponents.minute ?? 0,
                                                                 second: 0,
                                                                 of: selectedDate) ?? selectedDate
                                }
                        dismiss()
                    }
                }
            }
        }
        .accentColor(.blue)
    }
}
