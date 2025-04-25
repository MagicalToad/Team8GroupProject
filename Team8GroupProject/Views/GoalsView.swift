//
//  GoalsView.swift
//  Team8GroupProject
//
//  Created by Thoene, Zachary on 4/7/25.
//

import SwiftUI
import Charts

struct Goal: Identifiable {
    let id = UUID()            // Unique identifier for each goal
    var title: String          // The name or description of the goal
    var icon: String           // SF Symbol name to represent the goal visually
    var progress: Int          // Current progress percentage
    var history: [ProgressEntry]  // Timeline of progress updates for charting
}

struct ProgressEntry: Identifiable {
    let id = UUID()    // Unique identifier for each history entry
    let date: Date     // When this progress value was recorded
    let progress: Int  // Progress value at that date
}

struct Achievement: Identifiable {
    let id = UUID()    // Unique identifier for the achievement badge
    var title: String  // Text to display
    var icon: String   // SF Symbol name for the badge
    var color: Color   // Background color for the badge icon
}

// Manages the list of goals and completed goals counter
class GoalsViewModel: ObservableObject {
    @Published var goals: [Goal] = []       // All active goals
    @Published var completedCount: Int = 0  // How many goals have been finished

    // Add a new goal with zero progress and initial history entry
    func addGoal(title: String, icon: String) {
        let new = Goal(
            title: title,
            icon: icon,
            progress: 0,
            history: [ProgressEntry(date: Date(), progress: 0)]
        )
        goals.append(new)
    }
    
    // Remove goals at the specified index set
    func removeGoal(at offsets: IndexSet) {
        goals.remove(atOffsets: offsets)
    }
    
    // Update a goal’s progress; if it reaches or exceeds 100%, mark it completed
    func update(_ goal: Goal, to newProgress: Int) {
        guard let idx = goals.firstIndex(where: { $0.id == goal.id }) else { return }
        
        if newProgress >= 100 {
            // Remove the goal from the list and increment the completed counter
            goals.remove(at: idx)
            completedCount += 1
        } else {
            // Otherwise, update the progress and append a new history entry
            goals[idx].progress = newProgress
            goals[idx].history.append(ProgressEntry(date: Date(), progress: newProgress))
        }
    }
    
    // Create a single achievement badge that reads
    var completionAchievement: Achievement {
        let noun = completedCount == 1 ? "goal" : "goals"
        return Achievement(
            title: "\(completedCount) \(noun) completed",
            icon: "rosette",
            color: .green
        )
    }
}

// Main View: Shows current goals, button to add new goals, achievements, and chart
struct GoalsView: View {
    @EnvironmentObject var vm: GoalsViewModel
    @State private var showingAdd = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Display the horizontal list of active goals
                    CurrentGoalsSection(vm: vm)
                    
                    // Button to present the AddGoalView sheet
                    Button {
                        showingAdd = true
                    } label: {
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
                    .sheet(isPresented: $showingAdd) {
                        AddGoalView(vm: vm)
                    }

                    // Only show the achievement badge if at least one goal is completed
                    if vm.completedCount > 0 {
                        VStack(alignment: .leading, spacing: 10) {
                            SectionHeader(title: "My Achievements", icon: "rosette")
                            AchievementBadge(
                                title: vm.completionAchievement.title,
                                icon: vm.completionAchievement.icon,
                                color: vm.completionAchievement.color
                            )
                        }
                        .padding(.horizontal)
                    }

                    // Display the progress-over-time chart
                    ProgressChartSection(vm: vm)
                }
                .padding()
            }
            .navigationTitle("My Goals")
        }
    }
}

// Section showing all current goals in a horizontal scroll
struct CurrentGoalsSection: View {
    @ObservedObject var vm: GoalsViewModel

    var body: some View {
        VStack(alignment: .leading) {
            SectionHeader(title: "Current Goals", icon: "target")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(vm.goals) { goal in
                        GoalCard(
                            goal: goal,
                            onUpdate: { newProg in vm.update(goal, to: newProg) },
                            onRemove: {
                                if let idx = vm.goals.firstIndex(where: { $0.id == goal.id }) {
                                    vm.removeGoal(at: IndexSet(integer: idx))
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// A single goal card with a circular progress indicator and remove button
struct GoalCard: View {
    var goal: Goal
    var onUpdate: (Int) -> Void
    var onRemove: () -> Void

    @State private var editing = false
    @State private var tempProgress: Double = 0

    var body: some View {
        VStack(spacing: 15) {
            // Circular progress ring with icon in the center
            ZStack {
                Circle()
                    .stroke(lineWidth: 8)
                    .opacity(0.3)
                    .foregroundColor(.blue)
                
                Circle()
                    .trim(from: 0, to: CGFloat(goal.progress) / 100)
                    .stroke(style: .init(lineWidth: 8, lineCap: .round))
                    .foregroundColor(.blue)
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: goal.icon)
                    .font(.title2)
            }
            .frame(width: 80, height: 80)

            // Title and percentage text
            Text(goal.title)
                .font(.subheadline.bold())
                .multilineTextAlignment(.center)
            Text("\(goal.progress)%")
                .font(.caption.bold())
                .foregroundColor(.blue)

            // Button to bring up slider sheet for updating progress
            Button("Update") {
                tempProgress = Double(goal.progress)
                editing = true
            }
            .font(.caption)
            .sheet(isPresented: $editing) {
                VStack(spacing: 16) {
                    Text("Update “\(goal.title)”")
                        .font(.headline)
                    Slider(value: $tempProgress, in: 0...100, step: 1)
                        .padding(.horizontal)
                    Text("\(Int(tempProgress))%")
                        .bold()
                    Button("Save") {
                        onUpdate(Int(tempProgress))
                        editing = false
                    }
                    .padding(.top)
                }
                .presentationDetents([.fraction(0.3)])
            }
        }
        .padding()
        .frame(width: 150)
        .background(Color(.systemGray6))
        .cornerRadius(20)
        .overlay(alignment: .topTrailing) {
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.red)
            }
            .padding(6)
        }
    }
}

// A badge view used for displaying achievements
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

// Section displaying a line chart of progress history for all active goals
struct ProgressChartSection: View {
    @ObservedObject var vm: GoalsViewModel

    var body: some View {
        VStack(alignment: .leading) {
            SectionHeader(title: "Progress Overview", icon: "chart.bar")
            
            Chart {
                ForEach(vm.goals) { goal in
                    ForEach(goal.history) { entry in
                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("Progress", entry.progress),
                            series: .value("Goal", goal.title)
                        )
                        .symbol(by: .value("Goal", goal.title))
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 1)) { _ in
                    AxisGridLine()
                    AxisTick()
                }
            }
            .frame(height: 200)
            .padding(.vertical)
        }
    }
}

// Simple header view used in multiple sections
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

// View to add a new goal, including title entry and workout icon picker
struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: GoalsViewModel

    @State private var title = ""
    @State private var icon: String = "figure.walk" 
    // List of workout icons with friendly labels
    let iconOptions: [(label: String, symbol: String)] = [
        ("Walk",                        "figure.walk"),
        ("Run",                         "figure.run"),
        ("Yoga",                        "figure.yoga"),
        ("Dance",                       "figure.dance"),
        ("Cycling",                     "figure.indoor.cycle"),
        ("Strength Training",           "figure.strengthtraining.traditional"),
        ("Dumbbell",                    "dumbbell.fill"),
        ("Swimming",                    "figure.pool.swim"),
        ("Rowing",                      "figure.rower"),
        ("Hiking",                      "figure.hiking")
    ]

    var body: some View {
        NavigationStack {
            Form {
                // Goal title input
                TextField("Goal Title", text: $title)

                // Icon picker showing symbol and label
                Picker("Icon", selection: $icon) {
                    ForEach(iconOptions, id: \.symbol) { option in
                        HStack {
                            Image(systemName: option.symbol)
                            Text(option.label)
                        }
                        .tag(option.symbol)
                    }
                }
                .pickerStyle(.menu) // Renders as a dropdown
            }
            .navigationTitle("New Goal")
            .toolbar {
                // Confirm button disabled until title is non-empty
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        vm.addGoal(title: title, icon: icon)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
                // Cancel button to dismiss sheet
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}


struct GoalsView_Previews: PreviewProvider {
    static var previews: some View {
        GoalsView()
            .environmentObject(GoalsViewModel())
    }
}
