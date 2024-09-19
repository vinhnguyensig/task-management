//
//  SideMenuHeaderView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 18/9/24.
//
import SwiftUI

struct SideMenuHeaderView: View {
    
    @StateObject private var viewModel = SignInViewModel()
    @State private var isNavigateSignIn = false
    
    var body: some View {
        HStack(spacing: 12) {
            if let user = viewModel.user, let name = user.displayName, let url = user.photoURL {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                } placeholder: {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                        .overlay(
                            ProgressView()
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Button(action: {
                        viewModel.signOut()
                    }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                            .padding(.vertical, 8)
                    }
                }
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 40))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Not Signed In")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        viewModel.signInWithGoogle()
                    }) {
                        Text("Sign In")
                            .foregroundColor(.blue)
                            .padding(.vertical, 8)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
        .navigationDestination(isPresented: $isNavigateSignIn, destination: {
            SigninView()
        })
    }
}
