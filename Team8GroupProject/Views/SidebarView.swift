//
//  SidebarView.swift
//  Team8GroupProject
//
//  Created by Xiong, Chris on 4/15/25
//

import SwiftUI

// SidebarView
struct SidebarView: View {
    @Binding var selectedCategory: NavigationTarget?
    var onSelectItem: () -> Void

    var body: some View {
        List {
            // Buttons
            SidebarButton(title: "Home", systemImage: "house", target: .home, selection: $selectedCategory, action: onSelectItem)
            SidebarButton(title: "My Activity", systemImage: "figure.walk", target: .activity, selection: $selectedCategory, action: onSelectItem)
            SidebarButton(title: "My Goals", systemImage: "flag", target: .goals, selection: $selectedCategory, action: onSelectItem)
            SidebarButton(title: "My Planner", systemImage: "calendar", target: .planner, selection: $selectedCategory, action: onSelectItem)
            SidebarButton(title: "Social", systemImage: "person.2.fill", target: .social, selection: $selectedCategory, action: onSelectItem)
        }
        .listStyle(.sidebar)
    }
}

// Helper for Sidebar Buttons
struct SidebarButton: View {
    let title: String
    let systemImage: String
    let target: NavigationTarget
    @Binding var selection: NavigationTarget?
    let action: () -> Void

    var body: some View {
        Button {
            selection = target
            action() // Close sidebar on selection
        } label: {
            Label(title, systemImage: systemImage)
        }
        .buttonStyle(.plain)
        .foregroundStyle(selection == target ? Color.accentColor : Color.primary)
    }
}

// MARK: - Preview for SidebarView
struct SidebarView_Previews: PreviewProvider {

    @State static var previewSelection: NavigationTarget? = .home

    static var previews: some View {
         SidebarView(selectedCategory: $previewSelection, onSelectItem: {})
             .frame(width: 250)
         NavigationView {
             SidebarView(selectedCategory: $previewSelection, onSelectItem: {})
                .frame(width: 250)
                .navigationTitle("Menu Preview")
         }
    }
}
