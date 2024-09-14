//
//  EmptyTaskView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct EmptyTaskView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.clipboard")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.accentColor)
                .padding()
                .background(Circle().fill(Color(.systemGray5)))
                .frame(width: 140, height: 140)

            Text("Stay Organized")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Text("It looks like you don’t have any tasks yet. Tap the + button to add your first task and kickstart your productivity!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground).ignoresSafeArea())
    }
}
