//
//  ContentView.swift
//  Team8GroupProject
//
//  Created by Thoene, Zachary on 2/25/25.
//

import SwiftUI

// Navigation Target
enum NavigationTarget: Hashable {
    case home
    case activity
    case goals
    case planner
}

// ContentView
struct ContentView: View {
    @State private var isSidebarVisible = false
    @State private var selectedCategory: NavigationTarget? = .home
    private let sidebarWidth: CGFloat = UIScreen.main.bounds.width * 0.75

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {

                // Main Content Area
                CurrentDetailView(selectedCategory: $selectedCategory, toggleSidebar: toggleSidebar)

                // Dims when sidebar is showing
                if isSidebarVisible {
                     Color.black.opacity(0.5)
                         .ignoresSafeArea()
                         .onTapGesture { toggleSidebar() }
                         .transition(.opacity)
                         .zIndex(1)
                }

                // Sidebar
                SidebarView(selectedCategory: $selectedCategory, onSelectItem: toggleSidebar)
                    .frame(width: sidebarWidth)
                    .background(.regularMaterial)
                    .offset(x: isSidebarVisible ? 0 : -sidebarWidth)
                    .transition(.move(edge: .leading))
                    .zIndex(2)

            }
            .animation(.easeInOut, value: isSidebarVisible)
            .gesture(
                 DragGesture(minimumDistance: 30, coordinateSpace: .local)
                     .onEnded { value in
                         if !isSidebarVisible && value.translation.width > 50 && abs(value.translation.height) < 50 {
                             withAnimation { isSidebarVisible = true }
                         } else if isSidebarVisible && value.translation.width < -50 && abs(value.translation.height) < 50 {
                             withAnimation { isSidebarVisible = false }
                         }
                     }
             )
        }
    }

    func toggleSidebar() {
        isSidebarVisible.toggle()
    }
}

// CurrentDetailView
struct CurrentDetailView: View {
     @Binding var selectedCategory: NavigationTarget?
     var toggleSidebar: () -> Void

    @AppStorage("loggedIn") private var loggedIn = false // Log-in state
    
    // Dummy data of 10%
     @State private var goalProgress_merged: CGFloat = 0.1

     var body: some View {
         NavigationStack {
              Group {
                  switch selectedCategory {
                  case .home:
                      ScrollView {
                          VStack(spacing: 20) {
                              VStack {
                                  Text("Goal 1") // Dummy data
                                      .font(.headline)
                                  ZStack {
                                      Circle()
                                          .stroke(lineWidth: 8)
                                          .foregroundColor(.blue.opacity(0.3))

                                      Circle()
                                          .trim(from: 0, to: goalProgress_merged)
                                          .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                          .foregroundColor(.blue)
                                          .rotationEffect(Angle(degrees: -90))

                                      Text("\(Int(goalProgress_merged * 100))%")
                                          .font(.title.bold())
                                          .contentTransition(.numericText())
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
                                          .foregroundColor(.yellow)
                                      Text("Example reminder")
                                      Spacer()
                                  }
                                  .padding()
                                  .background(Color(.systemGray6))
                                  .cornerRadius(10)
                              }
                              .padding(.horizontal)

                              // Friend activity
                              VStack(alignment: .leading) {
                                  Text("Friend Activity")
                                      .font(.headline)
                                      .padding([.leading, .top])
                                  VStack(alignment: .leading, spacing: 10) {
                                      Text("Example activity from a friend.")
                                          .font(.footnote)
                                  }
                                  .padding()
                                  .frame(maxWidth: .infinity, alignment: .leading)
                                  .background(Color(.systemGray6))
                                  .cornerRadius(10)
                              }
                               .padding(.horizontal)

                              Spacer()

                            // LOG OUT BUTTON - FOR TESTING
                              Button("Log Out (Debug)", role: .destructive){
                                  loggedIn = false
                              }
                              .padding()
                              .buttonStyle(.borderedProminent)
                          }
                          .padding(.vertical)
                      }
                  case .activity:
                      ActivityView()
                  case .goals:
                      GoalsView()
                  case .planner:
                      PlannerView()
                  case nil:
                      Text("Select an item") // Fallback view
                  }
              }
              .navigationTitle(navigationTitle)
              .navigationBarTitleDisplayMode(.inline)
              .toolbar {
                  ToolbarItem(placement: .navigationBarLeading) {
                      Button {
                          toggleSidebar()
                      } label: {
                          Image(systemName: "line.3.horizontal")
                      }
                  }
              }
         }
         .tint(Color.primary)
     }

    // Navigation titles
    private var navigationTitle: String {
        switch selectedCategory {
            case .home: return "Home"
            case .activity: return "My Activity"
            case .goals: return "My Goals"
            case .planner: return "My Planner"
            case nil: return "Welcome"
        }
    }
}


// MARK: - Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

