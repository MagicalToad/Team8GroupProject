//
//  AddWorkoutView.swift
//  Team8GroupProject
//
//  Created by Xiong, Chris on 4/15/25.
//

import SwiftUI

struct WorkoutTypeInfo: Identifiable, Hashable {
    let id = UUID()
    let displayName: String
    let rawValue: String
}

struct AddWorkoutView: View {
    @ObservedObject var viewModel: ActivityViewModel
    @Environment(\.dismiss) var dismiss
    
    // Options for the Workout Type Picker
    let workoutTypeOptions: [WorkoutTypeInfo] = [
        .init(displayName: "🏃 Running", rawValue: "Running"),
        .init(displayName: "🏋️ Weightlifting", rawValue: "Weightlifting"),
        .init(displayName: "🚴 Cycling", rawValue: "Cycling"),
        .init(displayName: "🤸 Calisthenics", rawValue: "Calisthenics"),
    ]
    
    
    @State private var selectedWorkoutTypeRawValue: String = "Weightlifting" // Default selection
    @State private var durationHours: Int = 0
    @State private var durationMinutes: Int = 0 // Default duration
    @State private var workoutDate: Date = .now
    @State private var notes: String = ""
    
    // State for fields shown conditionally
    @State private var exerciseName: String = ""
    @State private var sets: Int = 3             // Default sets
    @State private var reps: Int = 10            // Default reps
    @State private var weightLbs: Double = 0.0
    @State private var distanceMiles: Double = 0.0
    
    private var isStrength: Bool {
        selectedWorkoutTypeRawValue == "Weightlifting" || selectedWorkoutTypeRawValue == "Calisthenics"
    }
    private var isDistance: Bool {
        selectedWorkoutTypeRawValue == "Running" || selectedWorkoutTypeRawValue == "Cycling"
    }
    
//    private let kgPerLb = 0.45359237
//    private let milesPerKm = 0.621371
    
    // Main view
    var body: some View {
        NavigationView {
            Form {
                // Pick workout
                Picker("Workout Type", selection: $selectedWorkoutTypeRawValue) {
                    ForEach(workoutTypeOptions, id: \.rawValue) { option in
                        Text(option.displayName).tag(option.rawValue)
                    }
                }
                .animation(.default, value: selectedWorkoutTypeRawValue) // Animate changes
                
                // Set date
                DatePicker("Date", selection: $workoutDate, displayedComponents: .date)
                
                // Conditional fields for strength workout
                if isStrength {
                    Section("Exercise Details") {
                        TextField("Exercise Name", text: $exerciseName)
                        Stepper("Sets: \(sets)", value: $sets, in: 1...99)
                        Stepper("Reps: \(reps)", value: $reps, in: 1...99)
                        
                        // Weightlighting weights only
                        if selectedWorkoutTypeRawValue == "Weightlifting" {
                            Stepper("Weight: \(weightLbs.formatted(.number.precision(.fractionLength(1)))) lbs", value: $weightLbs,
                                    in: 0...500,
                                    step: 5.0) // Increment option
                        }
                    }
                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
                }
                
                // Conditional fields for running/cycling workout
                else if isDistance {
                    Section("Distance") {
                        Stepper("Distance: \(distanceMiles.formatted(.number.precision(.fractionLength(1)))) miles",
                                value: $distanceMiles,
                                in: 0...100,
                                step: 0.5) // Increment option
                    }
                    
                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
                    
                    // Duration of run/cycle
                    Section("Duration") {
                        Stepper("\(durationHours) hr", value: $durationHours, in: 0...23)
                        Stepper("\(durationMinutes) min", value: $durationMinutes, in: 0...59, step: 5)
                        Text("Total: \(formattedTotalDuration)") // Formatted total
                            .font(.title)
                            .foregroundColor(.green)
                    }
                }
                
                // Notes
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(height: 80)
                }
            }
            .navigationTitle("Log New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                // Save Button
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveWorkout() // Call save function
                        dismiss()
                    }
                    // Disable save button if no duration and no specific details entered
                    .disabled(totalDuration <= 0 && !hasSpecificDetails())
                }
            }
        }
    }
    
    // MARK: - Helper functions
    
    // Calculates total duration in seconds from hours and minutes
    private var totalDuration: TimeInterval {
        TimeInterval((durationHours * 60 * 60) + (durationMinutes * 60))
    }
    
    // Formats the total duration for display
    private var formattedTotalDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: totalDuration) ?? ""
    }
    
    // Checks if exercise name or duration is entered
    private func hasSpecificDetails() -> Bool {
        if isStrength && !exerciseName.trimmingCharacters(in: .whitespaces).isEmpty { return true }
        if isDistance && distanceMiles > 0 { return true }
        return false
    }
    
    // Gathers data from @State variables and calls the ViewModel's log function
    private func saveWorkout() {
        let weightLbs = (selectedWorkoutTypeRawValue == "Weightlifting" && weightLbs > 0) ? weightLbs : nil
        let distanceMiles = isDistance && distanceMiles > 0 ? distanceMiles : nil
        
        // Process data for local store
        viewModel.logNewWorkout(
            type: selectedWorkoutTypeRawValue,
            duration: totalDuration,
            date: workoutDate,
            exerciseName: isStrength ? (exerciseName.isEmpty ? nil : exerciseName) : nil,
            sets: isStrength ? sets : nil,
            reps: isStrength ? reps : nil,
            weight: weightLbs,
            distance: distanceMiles,
            notes: notes.isEmpty ? nil : notes
        )
    }
}

// MARK: - Preview
struct AddWorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        AddWorkoutView(viewModel: ActivityViewModel())
    }
}
