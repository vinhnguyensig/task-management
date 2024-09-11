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
    @State private var selectedTime: Date = Date().addingTimeInterval(60*60*12)
    @State private var isExpanded: Bool = true
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        Button(action: {
                            // Handle tomorrow
                        }) {
                            Label("Tomorrow", systemImage: "sun.max.fill")
                                .foregroundColor(.blue)
                                .padding(.horizontal)
                        }
                        
                        Button(action: {
                            // Handle next week
                        }) {
                            Label("Next Week", systemImage: "arrow.right.circle.fill")
                                .foregroundColor(.blue)
                                .padding(.horizontal)
                        }
                       
                        Button(action: {
                            // Handle no date
                        }) {
                            Label("No Date", systemImage: "minus.circle")
                                .foregroundColor(.gray)
                                .padding(.horizontal)
                        }
                        
                        Spacer()
                    }
                }
                .padding()
                
                Divider()
                
                // Calendar View
                DueDateCalendarView(viewModel: viewModel, selectedDate: $selectedDate, isExpanded: $isExpanded)

                Divider()
                
                // Time Picker
                DatePicker("Select Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
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
                        dismiss()
                    }
                }
            }
        }
        .accentColor(.blue)
    }
}
