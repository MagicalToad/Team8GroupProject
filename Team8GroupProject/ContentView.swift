//
//  ContentView.swift
//  Team8GroupProject
//
//  Created by Thoene, Zachary on 2/25/25.
//

import SwiftUI


// Navigation menu
struct SidebarView: View {
    var body: some View {
        List {
            NavigationLink(destination: HomeView()) {
                Label("Home", systemImage: "house")
            }
            NavigationLink(destination: Text("My Activity")) {
                Label("My Activity", systemImage: "person")
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Menu")
    }
}

// Home menu
struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Goal Progress
                VStack {
                    Text("Goal 1")
                        .font(.headline)
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 8)
                            .opacity(0.3)
                            .foregroundColor(.blue)
                        
                        Circle()
                            .trim(from: 0, to: 0)
                            .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .foregroundColor(.blue)
                        
                        VStack {
                            Text("0%")
                                .font(.title)
                        }
                    }
                    .frame(width: 150, height: 150)
                    .padding()
                }
                
                // Reminders
                VStack(alignment: .leading) {
                    Text("Reminders")
                        .font(.headline)
                        .padding(.bottom, 5)
                    
                    HStack {
                        Image(systemName: "bell.fill")
                        Text("Example reminder")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                
                // Friend Activity
                VStack(alignment: .leading) {
                    Text("Friend Activity")
                        .font(.headline)
                        .padding()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Example activity")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image(systemName: "person.circle")
                }
            }
        }
    }
}


struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            SidebarView()
        } detail: {
            HomeView()
        }
    }
}


#Preview {
    ContentView()
}
