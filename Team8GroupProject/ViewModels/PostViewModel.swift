//
//  PostViewModel.swift
//  Team8GroupProject
//
//  Created by Thoene, Zachary on 4/24/25.
//


import FirebaseFirestore
import FirebaseAuth
import SwiftUI

struct Post: Identifiable {
    var id: String
    var category: String
    var message: String
    var timestamp: Date
    var userEmail: String
}


class PostViewModel: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var activities: [ActivityModel] = []
    @Published var errorMessage: String?
    @Published var friendListDidChange = false

    
    @Published private var friendUIDs: [String] = []
    
    func fetchFriendUIDsAndPosts() {
            guard let uid = Auth.auth().currentUser?.uid else {
                errorMessage = "User not authenticated."
                return
            }
            
            // Fetch the list of friend UID's
            db.collection("users").document(uid).collection("friends").getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = "Error fetching friends: \(error.localizedDescription)"
                    return
                }
                guard let documents = snapshot?.documents else {
                    self.errorMessage = "No friends found."
                    return
                }
                self.friendUIDs = documents.compactMap { $0.data()["uid"] as? String }
                
                // Fetch the activities of friends
                if !self.friendUIDs.isEmpty {
                    self.fetchActivitiesFromFriends()
                } else {
                    self.activities = []
                }
            }
        }
        
        private func fetchActivitiesFromFriends() {
            db.collection("activities")
                .whereField("userId", in: friendUIDs)
                .order(by: "timestamp", descending: true)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        self.errorMessage = "Error fetching activities: \(error.localizedDescription)"
                        return
                    }
                    
                    guard let snapshot = snapshot else {
                        self.errorMessage = "No activities found."
                        return
                    }
                    
                    self.activities = snapshot.documents.compactMap { document in
                        try? document.data(as: ActivityModel.self)
                    }
                }
        }
}
