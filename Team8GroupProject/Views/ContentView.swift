//
//  ContentView.swift
//  Team8GroupProject
//
//  Created by Thoene, Zachary on 2/25/25.
//

import SwiftUI

// Navigation Target
enum NavigationTarget: Hashable {
    case home, activity, goals, planner
}

// ContentView
struct ContentView: View {
    @State private var isSidebarVisible = false
    @State private var selectedCategory: NavigationTarget? = .home
    @StateObject private var activityViewModel = ActivityViewModel()
    @StateObject private var goalsViewModel = GoalsViewModel()

    private let sidebarWidth: CGFloat = UIScreen.main.bounds.width * 0.75

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Main Content Area
                CurrentDetailView(selectedCategory: $selectedCategory, toggleSidebar: toggleSidebar)
                    .environmentObject(activityViewModel)
                    .environmentObject(goalsViewModel)

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

// CurrentDetailView AKA Home
struct CurrentDetailView: View {
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @EnvironmentObject var goalsViewModel: GoalsViewModel
    @Binding var selectedCategory: NavigationTarget?
    var toggleSidebar: () -> Void

    @AppStorage("loggedIn") private var loggedIn = false // Log-in state

    var body: some View {
        NavigationStack {
            Group {
                switch selectedCategory {
                case .home:
                    ScrollView {
                        VStack(spacing: 15) {

                            VStack(alignment: .leading) {
                                Text("My Goals")
                                    .font(.headline)
                                    .padding(.horizontal)

                                if goalsViewModel.goals.isEmpty {
                                    Text("No goals yet")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal)
                                } else {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 20) {
                                            ForEach(goalsViewModel.goals) { goal in
                                                VStack(spacing: 8) {
                                                    Text(goal.title)
                                                        .font(.subheadline.bold())
                                                        .multilineTextAlignment(.center)
                                                    ZStack {
                                                        Circle()
                                                            .stroke(lineWidth: 6)
                                                            .foregroundColor(.blue.opacity(0.3))
                                                        Circle()
                                                            .trim(from: 0, to: CGFloat(goal.progress) / 100)
                                                            .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                                            .foregroundColor(.blue)
                                                            .rotationEffect(.degrees(-90))
                                                    }
                                                    .frame(width: 60, height: 60)
                                                    Text("\(goal.progress)%")
                                                        .font(.caption)
                                                        .foregroundColor(.blue)
                                                }
                                                .padding()
                                                .background(Color(.systemGray6))
                                                .cornerRadius(15)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            .padding(.top)

                            // Reminders
                            VStack(alignment: .leading) {
                                Text("Reminders")
                                    .font(.headline)
                                    .padding(.bottom, 5)
                                HStack {
                                    Image(systemName: "bell.fill").foregroundColor(.yellow)
                                    Text("Example reminder")
                                    Spacer()
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

                            // Recent Workouts
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Recent Activity")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Spacer()
                                }
                                .padding(.bottom, 5)

                                if activityViewModel.workouts.isEmpty {
                                    Text("No workouts logged yet.")
                                        .foregroundColor(.white)
                                        .padding(.vertical)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                } else {
                                    ForEach(activityViewModel.workouts.prefix(3)) { workout in
                                        VStack(alignment: .leading, spacing: 0) {
                                            ActivityRow(workout: workout)
                                            if workout.id != activityViewModel.workouts.prefix(3).last?.id {
                                                Divider().padding(.leading)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.black))
                            .cornerRadius(10)
                            .padding(.horizontal)

                            Spacer(minLength: 50)

                            // Log Out (Debug)
                            Button("Log Out (Debug)", role: .destructive) {
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
                    Text("Select an item")
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { toggleSidebar() } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
        }
        .tint(Color.primary)
    }

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
            .environmentObject(ActivityViewModel())
            .environmentObject(GoalsViewModel())
    }
}
