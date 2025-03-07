//
//  Team8GroupProjectApp.swift
//  Team8GroupProject
//
//  Created by Thoene, Zachary on 2/25/25.
//

import SwiftUI

@main
struct Team8GroupProjectApp: App {
    @AppStorage("loggedIn") private var loggedIn = false
    
    var body: some Scene {
        WindowGroup {
            // Shows OnBoardingView for first time users
            if loggedIn {
                ContentView()
            } else {
                OnboardingView()
            }
        }
    }
}
