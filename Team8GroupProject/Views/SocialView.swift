//
//  SocialView.swift
//  Team8GroupProject
//
//  Created by Thoene, Zachary on 4/7/25.
//

import SwiftUI

struct SocialView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Share Your Activity Button
                Button(action: {
                    print("Activity Button Clicked!")
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("Share Your Activity")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Friends Activity Feed
                VStack(alignment: .leading, spacing: 16) {
                    Text("Friend Activity")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    // Example Activity Items
                    VStack(spacing: 16) {
                        ActivityItem(message: "Friend Alex has run 5 miles today")
                        ActivityItem(message: "Friend Sam has completed their goal of 10 workouts this month")
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Social")
        .toolbarColorScheme(.dark, for: .navigationBar) // Force dark mode
        .toolbarBackground(Color.black, for: .navigationBar) // Black background
        .toolbarBackground(.visible, for: .navigationBar)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct ActivityItem: View {
    let message: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .frame(width: 40, height: 40)
                .foregroundColor(.blue.opacity(0.3))
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                )
            
            Text(message)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
     SocialView()
 }
