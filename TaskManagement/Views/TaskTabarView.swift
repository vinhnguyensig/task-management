//
//  TaskTabBarView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 10/9/24.
//

import SwiftUI

struct TaskTabBarView: View {
    @State private var selectedTab: Tab = .home
    @State private var showAddTaskView: Bool = false

    enum Tab {
        case home, tasks, add, calendar, menu
    }

    var body: some View {
        ZStack {
            contentView(for: selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack {
                Spacer()
                customTabBar
            }
            .sheet(isPresented: $showAddTaskView, onDismiss: {
                selectedTab = .tasks
            }) {
                AddTaskView()
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    // Function to handle content switching based on selectedTab
    @ViewBuilder
    private func contentView(for tab: Tab) -> some View {
        switch tab {
        case .home:
            DashboardView()
        case .tasks:
            TaskListView()
        case .calendar:
            TaskCalendarView()
        case .menu:
            SideMenuView()
        default:
            TaskListView()
        }
    }
    
    // Extracted custom tab bar
    private var customTabBar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color(UIColor.systemGray6))
                .frame(height: 80)
                .edgesIgnoringSafeArea(.bottom)
            
            HStack {
                TabBarButton(icon: "gauge.with.dots.needle.67percent", selectedTab: $selectedTab, currentTab: .home)
                Spacer()
                TabBarButton(icon: "list.bullet.clipboard", selectedTab: $selectedTab, currentTab: .tasks)
                Spacer()
                Button(action: {
                    showAddTaskView = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        selectedTab = .add
                    }
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                        .frame(width: 64, height: 64)
                        .background(Circle().fill(Color.accentColor))
                        .shadow(color: Color.accentColor.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.top, -40)
                Spacer()
                TabBarButton(icon: "calendar", selectedTab: $selectedTab, currentTab: .calendar)
                Spacer()
                TabBarButton(icon: "ellipsis.circle", selectedTab: $selectedTab, currentTab: .menu)
            }
            .padding(.horizontal)
        }
    }
}

struct TabBarButton: View {
    var icon: String
    @Binding var selectedTab: TaskTabBarView.Tab
    var currentTab: TaskTabBarView.Tab

    var body: some View {
        Button(action: {
            withAnimation {
                selectedTab = currentTab
            }
        }) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(selectedTab == currentTab ? Color.accentColor : Color(UIColor.systemGray))
                .frame(maxWidth: .infinity)
        }
    }
}
