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
            Text("Looks like there are no tasks available right now!")
                .font(.title2)
                .foregroundColor(.gray)
        }
        .padding()
    }
}
