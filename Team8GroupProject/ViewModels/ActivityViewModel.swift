//
//  ActivityViewModel.swift
//  Team8GroupProject
//
//  Created by Xiong, Chris on 4/15/25.
//

import SwiftUI
import Combine
import FirebaseFirestore
import FirebaseAuth

class ActivityViewModel: ObservableObject {
    @Published var workouts: [WorkoutLog] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    @Published private(set) var listenerActiveForUserID: String? = nil
    
    private var db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    private var authListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        addAuthStateListener()
    }
    
    // Clean up
    deinit {
        listenerRegistration?.remove()
        if let handle = authListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // Listen for Logins/Logouts
    private func addAuthStateListener() {
        authListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            let newUserID = user?.uid
            print("Auth State Changed: UserID = \(newUserID ?? "nil")")
            
            // If the user logged in/out, update listener
            if self.listenerActiveForUserID != newUserID {
                self.fetchWorkouts()
            }
        }
    }
    
    // MARK: - Get workouts from database
    
    // Get workouts
    func fetchWorkouts() {
        listenerRegistration?.remove()
        listenerRegistration = nil
        listenerActiveForUserID = nil
        
        // Make sure user is logged in
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: User not logged in.")
            self.errorMessage = "You must be logged in to see activity."
            self.workouts = []
            return
        }
        
        print("Setting up listener for user: \(userId)")
        self.isLoading = true
        self.errorMessage = nil
        
        // Listener object
        listenerRegistration = db.collection("workouts")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                // Main UI thread
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    guard userId == Auth.auth().currentUser?.uid else {
                        return
                    }
                    
                    self.isLoading = false // Loading finished once data/error
                    
                    if let error = error {
                        print("Error getting workout snapshots: \(error.localizedDescription)")
                        self.errorMessage = "Failed to load workouts."
                        self.workouts = []
                        self.listenerActiveForUserID = nil // Listener failed
                        return
                    }
                    
                    guard let documents = querySnapshot?.documents else {
                        print("No workout documents found.")
                        self.workouts = []
                        self.listenerActiveForUserID = userId // Listener active, but no data
                        return
                    }
                    
                    // Attach Firestore to WorkoutLog objects
                    self.workouts = documents.compactMap { document -> WorkoutLog? in
                        do {
                            return try document.data(as: WorkoutLog.self)
                        } catch {
                            print("Failed data: \(document.data())")
                            return nil
                        }
                    }
                    self.errorMessage = nil
                    self.listenerActiveForUserID = userId
                }
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
        
        // Get userID
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Error: User not logged in. Cannot log workout.")
            self.errorMessage = "Cannot log workout. Please log in." // Users see this
            return
        }
        
        // Filter irrelevant data
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
            iconName: self.determineIcon(for: type), // Get appropriate icon
            userId: userId
        )
        
        do {
            // encode the Codable object and add with auto-generated ID
            let _ = try db.collection("workouts").addDocument(from: newWorkout) { error in
                if let error = error {
                    print("Error adding workout document: \(error.localizedDescription)")
                    self.errorMessage = "Failed to save workout."
                } else {
                    print("Workout successfully saved to Firestore!")
                }
            }
        } catch {
            print("Error encoding workout before saving: \(error.localizedDescription)")
            self.errorMessage = "Failed to save workout (encoding error)."
        }
    }
    
    // MARK: - Delete function
    func deleteWorkouts(idsToDelete: Set<String>) {
        guard !idsToDelete.isEmpty else { return }
        print("Deleting Workouts via ID: \(idsToDelete)")
        
        let batch = db.batch() // Use batch to try to delete multiples
        
        idsToDelete.forEach { workoutId in
            let docRef = db.collection("workouts").document(workoutId)
            batch.deleteDocument(docRef)
        }
        
        // Batch commits
        batch.commit { error in
            if let error = error {
                print("Batch delete failed:" ,error.localizedDescription)
                self.errorMessage = "Failed to delete workout(s)."
            } else {
                print("Successfully deleted \(idsToDelete.count) workouts from Firestore.")
            }
        }
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
    
    func refreshData() {
        print("Refresh data requested.")
        fetchWorkouts()
    }
    
}
