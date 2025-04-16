//
//  Team8GroupProjectApp.swift
//  Team8GroupProject
//
//  Created by Thoene, Zachary on 2/25/25.
//

import SwiftUI
import Firebase
import FirebaseAuth

@main
struct Team8GroupProjectApp: App {
    // Configure Firebase on app launch
    init() {
        FirebaseApp.configure()
    }
    
    // Our in-memory storage for plans
    @StateObject var planStore = PlanStore()
    
    // User login state (stored persistently)
    @AppStorage("loggedIn") private var loggedIn = false
    
    var body: some Scene {
        WindowGroup {
            // Conditionally show the onboarding or the main content
            if loggedIn {
                // Inject the planStore as an environment object so that
                // views like DayDetailsView and AddPlansView can access it.
                ContentView()
                    .environmentObject(planStore)
            } else {
                OnboardingView()
            }
        }
    }
}
