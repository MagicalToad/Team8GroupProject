//
//  ActivityViewModel.swift
//  Team8GroupProject
//
//  Created by Xiong, Chris on 4/15/25.
//

import SwiftUI
import Combine
import Foundation

class ActivityViewModel: ObservableObject {

    // The array of workout logs
    @Published var workouts: [WorkoutLog] = [] {
        didSet {
            saveWorkoutsToFile()
        }
    }

    // File URL for save/load
    private var dataFileURL: URL {
        do {
            let documentsDirectory = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            // Append filename
            return documentsDirectory.appendingPathComponent("workoutLogs.json") // Saving as JSON
        } catch {
            // Error message
            fatalError("Error: Could not locate or create directory. \(error)")
        }
    }

    // Load data when the ViewModel is created
    init() {
        loadWorkoutsFromFile()
    }

    // MARK: - Data persistence logic

    // Loads the workout array from the JSON file
    func loadWorkoutsFromFile() {
        do {
            guard FileManager.default.fileExists(atPath: dataFileURL.path) else {
                print("Workout data file not found at \(dataFileURL.path). Starting with empty list.")
                self.workouts = []
                return
            }

            // Read data from URL
            let data = try Data(contentsOf: dataFileURL)
            let decoder = JSONDecoder()

            // Decode the JSON data into an array of WorkoutLog objects
            self.workouts = try decoder.decode([WorkoutLog].self, from: data)
            print("Loaded \(self.workouts.count) workouts from file: \(dataFileURL.path)")

        } catch {
            // Handle errors
            print("Error loading workouts from file: \(error)")
            print("File path attempted: \(dataFileURL.path)")
            self.workouts = []
        }
    }

    // Saves the current workout array to the JSON file
    private func saveWorkoutsToFile() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

            // Encode the workouts array into JSON data
            let data = try encoder.encode(workouts)
            try data.write(to: dataFileURL, options: [.atomicWrite, .completeFileProtection])
            print("Saved \(workouts.count) workouts to file: \(dataFileURL.path)")
        } catch {
            // Handle errors
            print("Error saving workouts to file: \(error)")
        }
    }

    // MARK: - Data modification logic

    func logNewWorkout(type: String,
                       duration: TimeInterval,
                       date: Date,
                       exerciseName: String?,
                       sets: Int?,
                       reps: Int?,
                       weight: Double?,
                       distance: Double?,
                       notes: String?) {

        let isStrength = (type == "Weightlifting" || type == "Calisthenics")
        let isCardioDistance = (type == "Running" || type == "Cycling")

        let finalExerciseName = isStrength ? (exerciseName?.isEmpty == false ? exerciseName : nil) : nil
        let finalSets = isStrength ? sets : nil
        let finalReps = isStrength ? reps : nil
        let finalWeight = (type == "Weightlifting") ? (weight ?? 0 > 0 ? weight : nil) : nil
        let finalDistance = isCardioDistance ? (distance ?? 0 > 0 ? distance : nil) : nil
        let finalNotes = notes?.isEmpty == false ? notes : nil

        // Create new WorkoutLog instance
        let newWorkout = WorkoutLog(
            date: date,
            type: type,
            duration: duration,
            exerciseName: finalExerciseName,
            sets: finalSets,
            reps: finalReps,
            weight: finalWeight,
            distance: finalDistance,
            notes: finalNotes,
            iconName: determineIcon(for: type) // Get appropriate icon
        )

        // Insert at the beginning so newest appears first in the list
        workouts.insert(newWorkout, at: 0)
        print("Logged new workout locally.")
    }
    
    // MARK: - Delete function
    func deleteWorkouts(idsToDelete: Set<UUID>) {
        guard !idsToDelete.isEmpty else { return }

        workouts.removeAll { workoutLog in
            idsToDelete.contains(workoutLog.id)
        }
        print("Deleted \(idsToDelete.count) workouts.")
    }

    // MARK: - Helper Methods

    // Determines SF symbol
    private func determineIcon(for type: String) -> String {
        switch type.lowercased() {
            case "running": return "figure.run"
            case "weightlifting": return "figure.strengthtraining.traditional"
            case "cycling": return "figure.outdoor.cycle"
            case "calisthenics": return "figure.strengthtraining.functional"
            default: return "figure.mixed.cardio"
        }
    }
}
