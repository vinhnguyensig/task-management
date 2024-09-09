//
//  EmptyTaskView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct EmptyTaskView: View {
    var body: some View {
        VStack {
            Image(systemName: "list.bullet.clipboard")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
            Text("No tasks available")
                .font(.title2)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

#Preview {
    EmptyTaskView()
}
