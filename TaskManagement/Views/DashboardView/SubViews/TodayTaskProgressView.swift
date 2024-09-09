//
//  TodayTaskProgressView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct TodayTaskProgressView: View {
    
    @State private var navigateToTaskList: Bool = false
    
    var body: some View {
        ZStack {
            // Background Shape
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hex: "AF52DE"), Color(hex: "6B60A0")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 180)
                .shadow(color: Color(hex: "AF52DE").opacity(0.5), radius: 10, x: 0, y: 5)

            HStack(alignment: .center, spacing: 20) {
                // Text Content
                VStack(alignment: .leading) {
                    Text("Your today's task")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("almost done!")
                        .font(.headline)
                        .foregroundColor(Color(hex: "E8E8E8"))
                    Spacer()
                    Button(action: {
                        navigateToTaskList = true
                    }) {
                        Text("View Task")
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.white)
                        .cornerRadius(8)
                        .foregroundColor(.purple)
                        .font(.headline)
                    }
                    .padding()
                }
                .padding(.leading, 20)

                Spacer()
                CircleProgressView(progress: 0.85, color: .green)
                    .frame(width: 80, height: 80)
                    .padding()
            }
            .padding(.vertical, 20)
            .navigationDestination(isPresented: $navigateToTaskList) {
                TaskListView()
            }
        }
    }
}
