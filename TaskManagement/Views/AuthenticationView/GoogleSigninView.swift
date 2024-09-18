//
//  GoogleSigninView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 18/9/24.
//

import Foundation
import SwiftUI

struct GoogleSigninView: View {
    @StateObject private var signInViewModel = SignInViewModel()

    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                signInViewModel.signInWithGoogle()
            }) {
                HStack {
                    Image(systemName: "globe")
                    Text("Sign in with Google")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity, minHeight: 44)
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
                .padding()
            }
            
            // Show error message if any
            if let errorMessage = signInViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            if let user = signInViewModel.user, let name = user.displayName {
                Text("Hello \(name)")
            }
            
            Spacer()
        }
        .padding()
    }
}
