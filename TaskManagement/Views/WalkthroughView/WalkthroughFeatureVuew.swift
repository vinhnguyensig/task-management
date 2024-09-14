//
//  WalkthroughFeatureVuew.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 14/9/24.
//

import SwiftUI

struct WalkthroughFeatureView: View {
    let imageName: String
    let title: String
    let description: String
    let accentColor: Color
    @State private var isVisible = false
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: imageName)
                .font(.system(size: 60))
                .foregroundColor(accentColor)
                .padding()
                .scaleEffect(isVisible ? 1.0 : 0.7)
                .opacity(isVisible ? 1.0 : 0.0)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .scaleEffect(isVisible ? 1.0 : 0.7)
                .opacity(isVisible ? 1.0 : 0.0)
            
            Text(description)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.gray)
                .opacity(isVisible ? 1.0 : 0.0)
            
            Spacer()
        }
        .padding()
        .offset(y: isVisible ? 0 : 200)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.4)) {
                isVisible = true
            }
        }
        .onDisappear {
            isVisible = false
        }
    }
}
