//
//  ToastView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 11/9/24.
//

import SwiftUI

struct ToastView: View {
    var message: String

    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.white)
            Text(message)
                .font(.body)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.green)
        .cornerRadius(10)
        .shadow(radius: 10)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}
