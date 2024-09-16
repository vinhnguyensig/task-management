//
//  CircleProgressView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 9/9/24.
//

import SwiftUI

struct CircleProgressView: View {
    var progress: Double
    var color: Color = .purple

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 6)
                .opacity(0.3)
                .foregroundColor(color)
            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)

            Text(String(format: "%.0f%%", min(progress, 1.0) * 100.0))
                .font(.caption)
                .bold()
                .foregroundColor(color)
        }
    }
}

struct LineProgressView: View {
    var progress: Double
    var color: Color = .purple

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 5)
                .frame(height: 10)
                .foregroundColor(color.opacity(0.3))
            
            RoundedRectangle(cornerRadius: 5)
                .frame(width: CGFloat(min(progress, 1.0)) * 200, height: 10)
                .foregroundColor(color)
                .animation(.linear, value: progress)
            
            Text(String(format: "%.0f%%", min(progress, 1.0) * 100.0))
                .font(.caption)
                .bold()
                .foregroundColor(color)
                .padding(.leading, 8)
        }
        .padding(.horizontal)
    }
}
