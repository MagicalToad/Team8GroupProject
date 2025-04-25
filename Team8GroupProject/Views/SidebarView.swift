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
    var onLogout: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            // Buttons
            SidebarButton(title: "Home", systemImage: "house", target: .home, selection: $selectedCategory, action: onSelectItem)
               
            SidebarButton(title: "My Activity", systemImage: "figure.walk", target: .activity, selection: $selectedCategory, action: onSelectItem)
              
            SidebarButton(title: "My Goals", systemImage: "flag", target: .goals, selection: $selectedCategory, action: onSelectItem)
               
            SidebarButton(title: "My Planner", systemImage: "calendar", target: .planner, selection: $selectedCategory, action: onSelectItem)
            
            SidebarButton(title: "Social", systemImage: "person.2.fill", target: .social, selection: $selectedCategory, action: onSelectItem)

            Spacer()
            
            // Logout Button
            Section {
                Button(role: .destructive) {
                    print("Log Out button tapped")
                    onLogout()
                } label: {
                    Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(Color.red)
                        .cornerRadius(8)
                }
                .listRowInsets(EdgeInsets())
                .padding(.horizontal, 10)
            }
            .padding(.vertical)
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
                    .font(.title3)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .buttonStyle(.plain)
            .foregroundStyle(selection == target ? Color.accentColor : Color.primary)
        }
    }
}
    

    struct SidebarView_Previews: PreviewProvider {
        @State static var previewSelection: NavigationTarget? = .home
        
        static var previews: some View {
            // Dummy action
            SidebarView(selectedCategory: $previewSelection, onSelectItem: {}, onLogout: { print("Preview Logout Tapped") })
                .frame(width: 250)
            
            NavigationView {
                SidebarView(selectedCategory: $previewSelection, onSelectItem: {}, onLogout: { print("Preview Logout Tapped") })
                    .frame(width: 250)
                    .navigationTitle("Menu Preview")
            }
        }
    }
