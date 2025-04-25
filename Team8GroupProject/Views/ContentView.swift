//
//  ContentView.swift
//  Team8GroupProject
//
//  Created by Thoene, Zachary on 2/25/25.
//

import SwiftUI
import FirebaseAuth

// Navigation Target
enum NavigationTarget: Hashable {
    case home
    case activity
    case goals
    case planner
    case social
}

// ContentView
struct ContentView: View {
    @AppStorage("loggedIn") private var loggedIn = true
    @StateObject var planStore = PlanStore()
    @StateObject private var activityViewModel = ActivityViewModel()
    @StateObject private var goalsViewModel = GoalsViewModel()
    @StateObject private var postViewModel = PostViewModel()

    
    @State private var isSidebarVisible = false
    @State private var selectedCategory: NavigationTarget? = .home
    
    private let sidebarWidth: CGFloat = UIScreen.main.bounds.width * 0.75
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                
                // Main Content Area
               CurrentDetailView(selectedCategory: $selectedCategory, toggleSidebar: toggleSidebar)
                    .environmentObject(activityViewModel)
                    .environmentObject(planStore)
                    .environmentObject(goalsViewModel)
                    .environmentObject(postViewModel)
                
                // Dims when sidebar is showing
                if isSidebarVisible {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture { toggleSidebar() }
                        .transition(.opacity)
                        .zIndex(1)
                }
                
                // Sidebar
                SidebarView(selectedCategory: $selectedCategory, onSelectItem: toggleSidebar, onLogout: logout)
                    .frame(width: sidebarWidth)
                    .background(.regularMaterial)
                    .offset(x: isSidebarVisible ? 0 : -sidebarWidth)
                    .transition(.move(edge: .leading))
                    .zIndex(2)
                    .environmentObject(activityViewModel)
                    .environmentObject(goalsViewModel)
                    .environmentObject(postViewModel)
                
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
        }.onAppear {
            postViewModel.fetchFriendUIDsAndPosts()  // Fetch posts when the view appears
        }
        .onReceive(NotificationCenter.default
                        .publisher(for: .friendsChanged)) { _ in
              postViewModel.fetchFriendUIDsAndPosts()
            }
        
        
    }
    
    // Sidebar func
    func toggleSidebar() {
        isSidebarVisible.toggle()
    }
    
    // Logout func
    private func logout() {
            print("Logging out")
            if isSidebarVisible {
                withAnimation { isSidebarVisible = false }
            }
            do {
                try Auth.auth().signOut()
                print("Successfully signed out.")
                self.loggedIn = false
            } catch let signOutError as NSError {
                print(signOutError)
            }
        }
}

// CurrentDetailView AKA Home
struct CurrentDetailView: View {
    @EnvironmentObject var planStore: PlanStore
    @EnvironmentObject var activityViewModel: ActivityViewModel
    @EnvironmentObject var postViewModel: PostViewModel
    @Binding var selectedCategory: NavigationTarget?
    @EnvironmentObject var goalsViewModel: GoalsViewModel
    
    var toggleSidebar: () -> Void
    
    var body: some View {
        NavigationStack {
            Group {
                switch selectedCategory {
                case .home:
                    ScrollView {
                        VStack(spacing: 15) {
                            // Main stack for home content
                            
                            // Goals
                            VStack(alignment: .leading) {
                                Text("My Goals")
                                    .font(.headline)
                                    .padding(.bottom, 5)
                                
                                VStack(alignment: .leading) {
                                    if goalsViewModel.goals.isEmpty {
                                        HStack {
                                            Image(systemName: "flag.fill")
                                                .foregroundColor(.blue)
                                            Text("No goals yet")
                                                .foregroundColor(.black)
                                            Spacer()
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        
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
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            
                            // Reminders
                            VStack(alignment: .leading) {
                                Text("Reminders")
                                    .font(.headline)
                                    .padding(.bottom, 5)
                                VStack(alignment: .leading) {
                                    HStack {
                                        Image(systemName: "bell.fill").foregroundColor(.blue)
                                        Text(planStore.plans.isEmpty ? "No reminders yet" : PlanUtilities.getReminderText(plans: planStore.plans))
                                        
                                        Spacer()
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    
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
                                    .padding(.bottom, 5)
                                VStack(alignment: .leading) {
                                    if postViewModel.activities.isEmpty {
                                        HStack {
                                            Image(systemName: "person.2.fill")
                                                .foregroundColor(.blue)
                                            Text("No friend activity yet")
                                                .foregroundColor(.black)
                                            Spacer()
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        
                                    } else {
                                        VStack(alignment: .leading, spacing: 10) {
                                            ForEach(postViewModel.activities.prefix(3)) { activity in
                                                VStack(alignment: .leading, spacing: 10) {
                                                    Text(activity.username)
                                                        .font(.caption)
                                                    Text(activity.category)
                                                        .font(.headline)
                                                    Text(activity.message)
                                                        .font(.body)
                                                    Text(activity.timestamp, style: .date)
                                                        .font(.caption)
                                                }
                                                .padding()
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(Color.white)
                                                .cornerRadius(10)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }

                            .padding(.horizontal)
                            
                            // Activity
                            
                            VStack(alignment: .leading) {
                                Text("Recent Activity")
                                    .font(.headline)
                                    .padding([.leading, .top])
                                
                                if activityViewModel.workouts.isEmpty {
                                    Text("No workouts logged yet.")
                                        .foregroundColor(Color.black)
                                        .padding(.vertical)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                    
                                } else {
                                    // Display first 3 workouts with ActivityRow component
                                    ForEach(activityViewModel.workouts.prefix(3)) { workout in
                                        
                                        VStack(alignment: .leading, spacing: 0) {
                                            ActivityRow(workout: workout)

                                            if workout.id != activityViewModel.workouts.prefix(3).last?.id {
                                                Divider()
                                                    .padding(.leading)
                                            }
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                    }
                                }
                            }
                            
                            
                            Spacer(minLength: 50)
                            
                            // LOG OUT BUTTON - FOR TESTING
//                            Button("Log Out (Debug)", role: .destructive){
//                                loggedIn = false
//                            }
//                            .padding()
//                            .buttonStyle(.borderedProminent)
//                            .foregroundColor(.white)
//                            .colorScheme(.light)
                            // --- End Logout Button ---
                            
                        } // End Main VStack for Home
                        .padding(.vertical) // Padding at top/bottom of scroll content
                    } // End ScrollView for Home
                    
                case .activity:
                    ActivityView()
                case .goals:
                    GoalsView()
                case .planner:
                    PlannerView()
                case .social:
                    MainSocialFeedView()
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
        .onAppear {
              postViewModel.fetchFriendUIDsAndPosts()
            }
        .onReceive(NotificationCenter.default
                        .publisher(for: .friendsChanged)) { _ in
              postViewModel.fetchFriendUIDsAndPosts()
            }
    }
    
    // Navigation titles
    private var navigationTitle: String {
        switch selectedCategory {
        case .home: return "Home"
        case .activity: return "My Activity"
        case .goals: return "My Goals"
        case .planner: return "My Planner"
        case .social: return "Social"
        case nil: return "Welcome"
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ActivityViewModel())
            .environmentObject(GoalsViewModel())
    }
}

