//
//  WorkoutLogModel.swift
//  Team8GroupProject
//
//  Created by Xiong, Chris on 4/15/25.
//

import Foundation
import FirebaseFirestore // Required for Timestamp

// Data Model for a single workout entry
struct WorkoutLog: Identifiable, Hashable, Codable {
    
    @DocumentID var id: String?
    
    let date: Date
    let type: String
    let duration: TimeInterval // Total duration in secs

    // Optional fields for specific details based on type
    let exerciseName: String?
    let sets: Int?
    let reps: Int?
    let weight: Double?
    let distance: Double?
    let notes: String?
    let iconName: String
    
    let userId: String?
    
//    private var milesPerKm = 0.621371
//    private var kgPerLb = 0.45359237
    
    // Custom initializer
    init(date: Date, type: String, duration: TimeInterval,
         exerciseName: String? = nil, sets: Int? = nil, reps: Int? = nil,
         weight: Double? = nil, distance: Double? = nil, notes: String? = nil,
         iconName: String, userId: String?) {
        self.date = date
        self.type = type
        self.duration = duration
        self.exerciseName = exerciseName
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.distance = distance
        self.notes = notes
        self.iconName = iconName
        self.userId = userId
    }
    

    // MARK: - Formats of date and duration

    var formattedDate: String {
        if Calendar.current.isDateInToday(date) { return "Today" }
        else if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        else { return date.formatted(.dateTime.month(.abbreviated).day()) }
    }

    var formattedDuration: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropLeading
        return formatter.string(from: duration) ?? ""
    }

    // Display list row
    var displaySummary: String {
         var parts: [String] = []
        
        // Name
        if let exerciseName = exerciseName, !exerciseName.isEmpty { parts.append(exerciseName) }
        // Sets/Reps
        if let sets = sets, let reps = reps { parts.append("\(sets)x\(reps)") }
        // Weights
        if let weightLbs = weight, weightLbs > 0 {
                parts.append("\(Int(weightLbs)) lbs") // Display pounds
              }
        // Distance
        if let distanceMiles = distance, distanceMiles > 0 {
            parts.append("\(distanceMiles.formatted(.number.precision(.fractionLength(1)))) miles") // Display miles
           }
        // Notes
         if let notes = notes, !notes.isEmpty { parts.append("Notes: \(notes)")}

         if parts.isEmpty { return notes ?? type }

         return parts.joined(separator: " / ")
     }
}
