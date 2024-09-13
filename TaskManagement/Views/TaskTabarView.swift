//
//  TaskTabBarView.swift
//  TaskManagement
//
//  Created by Vinh Nguyen on 10/9/24.
//

import SwiftUI

struct TaskTabBarView: View {
    @State private var selectedTab: Tab = .tasks
    @State private var showAddTaskView: Bool = false

    enum Tab {
        case tasks, home, add, calendar, menu
    }

    var body: some View {
        ZStack {
            contentView(for: selectedTab)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack {
                Spacer()
                customTabBar
            }
            .navigationBarBackButtonHidden()
            .sheet(isPresented: $showAddTaskView, onDismiss: {
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
        case .tasks:
            TaskListView()
        case .home:
            DashboardView()
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
                TabBarButton(icon: "list.bullet.clipboard", selectedTab: $selectedTab, currentTab: .tasks)
                Spacer()
                TabBarButton(icon: "gauge.with.dots.needle.67percent", selectedTab: $selectedTab, currentTab: .home)
                Spacer()
                Button(action: {
                    HapticManager.shared.triggerImpactFeedback(style: .medium)
                    showAddTaskView = true
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
            HapticManager.shared.triggerImpactFeedback(style: .light)
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
