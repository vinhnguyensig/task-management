//
//  WalkthroughView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 13/9/24.
//

import SwiftUI

struct WalkthroughView: View {
    @State private var currentPage = 0
    @State private var navigateHome = false
    
    var body: some View {
        NavigationStack {
            VStack {
                TabView(selection: $currentPage) {
                    WalkthroughFeatureView(
                        imageName: "checklist",
                        title: "Welcome to the Task Management App",
                        description: "Get organized and boost your productivity. Let's get started!",
                        accentColor: .green
                    )
                    .tag(0)
                    .transition(.move(edge: .bottom))
                    
                    WalkthroughFeatureView(
                        imageName: "list.bullet",
                        title: "Task List",
                        description: "View all your tasks in one place.",
                        accentColor: .blue
                    )
                    .tag(1)
                    .transition(.move(edge: .bottom))
                    
                    WalkthroughFeatureView(
                        imageName: "doc.text.magnifyingglass",
                        title: "Task Details",
                        description: "See task details and edit them easily.",
                        accentColor: .green
                    )
                    .tag(2)
                    .transition(.move(edge: .bottom))
                    
                    WalkthroughFeatureView(
                        imageName: "plus.circle",
                        title: "Add/Edit Task",
                        description: "Quickly add and edit tasks with a simple interface.",
                        accentColor: .orange
                    )
                    .tag(3)
                    .transition(.move(edge: .bottom))
                    
                    WalkthroughFeatureView(
                        imageName: "bell",
                        title: "Task Reminder",
                        description: "Get reminders for upcoming tasks.",
                        accentColor: .orange
                    )
                    .tag(4)
                    .transition(.move(edge: .bottom))
                    
                    WalkthroughFeatureView(
                        imageName: "chart.bar",
                        title: "Task Progress & Statistics",
                        description: "Track your progress and view task completion stats.",
                        accentColor: .purple
                    )
                    .tag(5)
                    .transition(.move(edge: .bottom))
                    
                    WalkthroughFeatureView(
                        imageName: "calendar",
                        title: "Task Due Dates",
                        description: "Stay organized with clear due dates.",
                        accentColor: .blue
                    )
                    .tag(6)
                    .transition(.move(edge: .bottom))
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 1), value: currentPage)
                
                PageControl(currentPage: $currentPage, numberOfPages: 7)
                
                Spacer()
                
                Button(action: {
                    if currentPage < 6 {
                        withAnimation(.easeInOut) {
                            currentPage += 1
                        }
                    } else {
                        UserDefaultsManager.save(value: true, forKey: Constants.isReopenApp)
                        navigateHome = true
                    }
                }) {
                    Text(currentPage < 6 ? "Next" : "Get Started")
                        .font(.headline)
                        .padding()
                        .padding(.horizontal, 30)
                        .frame(maxWidth: 350)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .scaleEffect(currentPage < 6 ? 1.05 : 1.1)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentPage)
                }
                .padding(.horizontal)
            }
            .navigationDestination(isPresented: $navigateHome) {
                GenerateTaskView(isFromWalkthough: true)
            }
        }
    }
}

struct PageControl: View {
    @Binding var currentPage: Int
    let numberOfPages: Int
    
    var body: some View {
        HStack {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.5))
                    .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
        .padding(.vertical)
    }
}
