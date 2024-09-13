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
                    VStack {
                        Spacer()
                        Image(systemName: "checklist")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                            .padding()
                        
                        Text("Welcome to the Task Management App")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Text("Get organized and boost your productivity. Let's get started!")
                            .font(.title2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .foregroundColor(.gray)
                        
                        Spacer()
                    }
                    .tag(0)
                    
                    WalkthroughFeatureView(
                        imageName: "list.bullet",
                        title: "Task List",
                        description: "View all your tasks in one place.",
                        accentColor: .blue
                    )
                    .tag(1)
                    
                    WalkthroughFeatureView(
                        imageName: "doc.text.magnifyingglass",
                        title: "Task Details",
                        description: "See task details and edit them easily.",
                        accentColor: .green
                    )
                    .tag(2)
                    
                    WalkthroughFeatureView(
                        imageName: "plus.circle",
                        title: "Add/Edit Task",
                        description: "Quickly add and edit tasks with a simple interface.",
                        accentColor: .orange
                    )
                    .tag(3)
                    
                    WalkthroughFeatureView(
                        imageName: "bell",
                        title: "Task Reminder",
                        description: "Get reminders for upcoming tasks.",
                        accentColor: .orange
                    )
                    .tag(4)
                    
                    WalkthroughFeatureView(
                        imageName: "chart.bar",
                        title: "Task Progress & Statistics",
                        description: "Track your progress and view task completion stats.",
                        accentColor: .purple
                    )
                    .tag(5)
                    
                    // Task Due Dates Feature
                    WalkthroughFeatureView(
                        imageName: "calendar",
                        title: "Task Due Dates",
                        description: "Stay organized with clear due dates.",
                        accentColor: .blue
                    )
                    .tag(6)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                PageControl(currentPage: $currentPage, numberOfPages: 7)
                
                Spacer()
                
                Button(action: {
                    if currentPage < 6 {
                        withAnimation {
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
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .navigationDestination(isPresented: $navigateHome) {
                TaskTabBarView()
            }
        }
    }
}

struct WalkthroughFeatureView: View {
    let imageName: String
    let title: String
    let description: String
    let accentColor: Color
    
    var body: some View {
        VStack {
            Spacer()
            Image(systemName: imageName)
                .font(.system(size: 60))
                .foregroundColor(accentColor)
                .padding()
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Text(description)
                .font(.title2)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.gray)
            Spacer()
        }
        .padding()
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
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical)
    }
}
