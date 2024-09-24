//
//  GenerateTaskView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 15/9/24.
//

import SwiftUI

struct GenerateTaskView: View {
    var isFromWalkthough: Bool = false
    
    @StateObject private var viewModel = GenerateTaskViewModel()
    @State private var requirement: String = ""
    @State private var isNavigateHome: Bool = false
    @State private var isGenerating: Bool = false
    @State private var isGeneratedSuccess: Bool = false
    @FocusState private var isFocus: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("Describe Your Tasks or Idea")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
                    .multilineTextAlignment(.center)
                    .padding(.top, 20)
                
                Text("Provide a requirement of the tasks or ideas you want to generate. The more specific you are, the more accurate the generated tasks will be.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                
              
                TextEditor(text: $requirement)
                    .frame(minHeight: 150, maxHeight: 300)
                    .padding(1)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .focused($isFocus)
                    .onAppear { isFocus = true }
                    .accessibilityLabel("Task or Idea Description")
                    .accessibilityHint("Enter the description of the task or idea you wish to generate.")
                
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .padding(.top, 5)
                }
                
                if isGeneratedSuccess {
                    Text("Generated tasks successful.")
                        .foregroundColor(.green)
                        .font(.headline)
                        .padding(.top, 5)
                    Spacer()
                    Button(action: {
                        isNavigateHome = true
                    }) {
                        Label("View Task List", systemImage: "paperplane.fill")
                           .frame(maxWidth: .infinity)
                           .padding()
                           .background(Color.blue)
                           .foregroundColor(.white)
                           .cornerRadius(10)
                           .font(.headline)
                                           
                    }
                }
                
                if viewModel.isLoading {
                    VStack(spacing: 8) {
                        ProgressView()
                        Text("Generating tasks...")
                            .font(.subheadline)
                            .foregroundColor(.orange)
                    }
                    .padding()
                } else if !isGeneratedSuccess {
                    Button(action: {
                        if !viewModel.isLoading {
                            isGenerating = true
                            isFocus = false
                            viewModel.generateTasks(requirement: requirement)
                        }
                    }) {
                        Label("Generate Tasks", systemImage: "sparkles")
                           .frame(maxWidth: .infinity)
                           .padding()
                           .background(requirement.isEmpty ? Color.gray : Color.blue)
                           .foregroundColor(.white)
                           .cornerRadius(10)
                           .font(.headline)
                                           
                    }
                    .disabled(requirement.isEmpty)
                    .accessibilityLabel("Generate Tasks Button")
                    .accessibilityHint("Tap to generate tasks based on your description.")
                }
                
                if isFromWalkthough {
                    Spacer()
                    Button {
                        isNavigateHome = true
                    } label: {
                        Text("Skip")
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Task Generator")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(isFromWalkthough)
            .navigationDestination(isPresented: $isNavigateHome) {
                if isFromWalkthough {
                    TaskTabBarView()
                } else {
                    TaskListView()
                }
            }
            .onReceive(viewModel.$isGenerateSuccess) { status in
                if status {
                    if isFromWalkthough {
                        isGeneratedSuccess = true
                    } else {
                        isNavigateHome = true
                    }
                }
            }
        }
    }
}
