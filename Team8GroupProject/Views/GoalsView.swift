//
//  GoalsView.swift
//  Team8GroupProject
//
//  Created by Thoene, Zachary on 4/7/25.
//

import SwiftUI

struct GoalsView: View {
    let goals = [
        ("Goal 1", 10, "figure.run"),
        ("Goal 2", 0, "figure.run"),
    ]
    
    let achievements = [
        ("Achievement 1", "medal", Color.orange),
        ("Achievement 2", "medal", Color.red),
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                
                CurrentGoalsSection(goals: goals)
                
                NewGoalButton()
                
                AchievementsSection(achievements: achievements)
                
                ProgressChartSection()
            }
            .padding()
        }
        .navigationTitle("My Goals")
    }
}

struct CurrentGoalsSection: View {
    let goals: [(String, Int, String)]
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionHeader(title: "Current Goals", icon: "target")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(goals, id: \.0) { goal in
                        GoalCard(title: goal.0, progress: goal.1, icon: goal.2)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct GoalCard: View {
    let title: String
    let progress: Int
    let icon: String
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .stroke(lineWidth: 8)
                    .opacity(0.3)
                    .foregroundColor(.blue)
                
                Circle()
                    .trim(from: 0, to: CGFloat(progress)/100)
                    .stroke(style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .foregroundColor(.blue)
                    .rotationEffect(Angle(degrees: -90))
                
                Image(systemName: icon)
                    .font(.title2)
            }
            .frame(width: 80, height: 80)
            
            Text(title)
                .font(.subheadline.bold())
                .multilineTextAlignment(.center)
            
            Text("\(progress)%")
                .font(.caption.bold())
                .foregroundColor(.blue)
        }
        .padding()
        .frame(width: 150)
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}

struct NewGoalButton: View {
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Create New Goal")
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(15)
        }
    }
}

struct AchievementsSection: View {
    let achievements: [(String, String, Color)]
    
    var body: some View {
        VStack(alignment: .leading) {
            SectionHeader(title: "My Achievements", icon: "rosette")
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 110))], spacing: 15) {
                ForEach(achievements, id: \.0) { achievement in
                    AchievementBadge(title: achievement.0, icon: achievement.1, color: achievement.2)
                }
            }
        }
    }
}

struct AchievementBadge: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.title)
                .padding(10)
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
            Text(title)
                .font(.caption.bold())
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

struct ProgressChartSection: View {
    var body: some View {
        VStack(alignment: .leading) {
            SectionHeader(title: "Progress Overview", icon: "chart.bar")
            
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray6))
                .frame(height: 200)
                .overlay(
                    Text("Progress Chart")
                        .foregroundColor(.secondary)
                )
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
                .font(.headline)
            Spacer()
        }
        .padding(.vertical, 5)
        .foregroundColor(.secondary)
    }
}

#Preview {
    GoalsView()
}
