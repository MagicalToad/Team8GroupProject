//
//  ActivityView.swift
//  Team8GroupProject
//
//  Created by Xiong, Chris on 4/15/25.
//

import SwiftUI

struct ActivityView: View {
    @StateObject private var viewModel = ActivityViewModel()
    @State private var showingAddSheet = false
    
    // Sort workouts
    private var groupedWorkouts: [Date: [WorkoutLog]] {
        Dictionary(grouping: viewModel.workouts) { workout in
            Calendar.current.startOfDay(for: workout.date)
        }
    }
    private var sortedDates: [Date] {
        groupedWorkouts.keys.sorted(by: >)
    }
    
    var body: some View {
        Group {
            if viewModel.workouts.isEmpty {
                Text("No Workout Logged Yet!") // Text display for no workouts
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List {
                    ForEach(sortedDates, id: \.self) { date in
                        let workoutsForDate = groupedWorkouts[date] ?? []
                        
                        Section {
                            ForEach(groupedWorkouts[date]!, id: \.id) { workout in
                                ActivityRow(workout: workout) // Existing row view
                            }
                            // Delete workouts
                            .onDelete { indexSet in
                                deleteItems(at: indexSet, from: workoutsForDate)
                            }
                        } header: {
                            Text(date, style: .date)
                                .textCase(nil)
                                .font(.title3)
                                .bold()
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        // Add workout toolbar
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddSheet = true // Set state to true to show the sheet
                } label: {
                    Label("Add Workout", systemImage: "plus")
                }
            }
        }
        // Add workout log if showingAddSheet = true
        .sheet(isPresented: $showingAddSheet) {
            AddWorkoutView(viewModel: viewModel)
        }
    }
    
    // Helper function for .delete modifier
    private func deleteItems(at offsets: IndexSet, from workoutList: [WorkoutLog]) {
        // Create set of IDs to delete
        var idsToDelete = Set<UUID>()
        for index in offsets {
            if index < workoutList.count {
                idsToDelete.insert(workoutList[index].id)
            }
        }
        
        // Call ViewModel's delete function with set of IDs
        if !idsToDelete.isEmpty {
            viewModel.deleteWorkouts(idsToDelete: idsToDelete)
        }
    }
}

// MARK: - ActivityRow
struct ActivityRow: View {
    let workout: WorkoutLog
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: workout.iconName)
                .font(.title2)
                .foregroundColor(.accentColor)
                .frame(width: 35, alignment: .leading)
            VStack(alignment: .leading) {
                Text(workout.type).font(.headline)
                Text(workout.displaySummary).font(.subheadline).foregroundColor(.secondary).lineLimit(2)
            }
            Spacer()
            Text(workout.formattedDuration).font(.subheadline).foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}


// MARK: - Preview
#Preview {
    NavigationStack {
        ActivityView()
    }
}
