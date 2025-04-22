//
//  SocialView.swift
//  Team8GroupProject
//
//  Created by Thoene, Zachary on 4/7/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

import Combine

// MARK: - Models
struct UserModel: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
}

struct ActivityModel: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var category: String
    var message: String
    var timestamp: Date
}

enum ActivityCategory: String, CaseIterable, Identifiable {
    case goalReached = "Goal Reached"
    case achievement = "Achievement"
    case activity = "Activity"
    
    var id: String { self.rawValue }
}

// MARK: - Managers
class FriendManager: ObservableObject {
    private let db = Firestore.firestore()
    
    @Published var friendEmailInput: String = ""
    @Published var friendsEmails: [String] = []
    @Published var errorMessage: String?

    func fetchFriends() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).collection("friends")
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    self.errorMessage = "Error fetching friends: \(error.localizedDescription)"
                    return
                }
                self.friendsEmails = snapshot?.documents.compactMap { $0.data()["email"] as? String } ?? []
            }
    }

    func addFriendByEmail() {
        let emailToAdd = friendEmailInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        guard emailToAdd != Auth.auth().currentUser?.email?.lowercased() else {
            self.errorMessage = "You can't add yourself."
            return
        }

        db.collection("users")
            .whereField("email", isEqualTo: emailToAdd)
            .getDocuments { snapshot, error in
                if let error = error {
                    self.errorMessage = "Lookup failed: \(error.localizedDescription)"
                    return
                }
                guard let document = snapshot?.documents.first else {
                    self.errorMessage = "No user with that email found."
                    return
                }
                let friendUID = document.documentID

                let friendData = [
                    "email": emailToAdd,
                    "uid": friendUID
                ]

                self.db.collection("users")
                    .document(currentUserUID)
                    .collection("friends")
                    .document(friendUID)
                    .setData(friendData) { error in
                        if let error = error {
                            self.errorMessage = "Failed to add friend: \(error.localizedDescription)"
                        } else {
                            self.friendEmailInput = ""
                            self.errorMessage = nil
                        }
                    }
            }
    }

    func removeFriend(uid: String) {
        guard let currentUserUID = Auth.auth().currentUser?.uid else { return }
        db.collection("users")
            .document(currentUserUID)
            .collection("friends")
            .document(uid)
            .delete { error in
                if let error = error {
                    self.errorMessage = "Failed to remove friend: \(error.localizedDescription)"
                }
            }
    }
}

class ActivityManager: ObservableObject {
    private let db = Firestore.firestore()
    @Published var errorMessage: String?

    func postActivity(category: String, message: String) {
        guard let user = Auth.auth().currentUser else {
            self.errorMessage = "User not authenticated."
            return
        }
        let newActivity = ActivityModel(
            userId: user.uid,
            category: category,
            message: message,
            timestamp: Date()
        )
        do {
            _ = try db.collection("activities").addDocument(from: newActivity)
            self.errorMessage = nil
        } catch {
            self.errorMessage = "Failed to post activity: \(error.localizedDescription)"
        }
    }
}

// MARK: - Views
struct AddFriendView: View {
    @StateObject private var manager = FriendManager()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add a Friend")
                .font(.title2.bold())
                .padding(.top)
            
            TextField("Enter friend's email", text: $manager.friendEmailInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            Button(action: manager.addFriendByEmail) {
                Text("Add Friend")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            if let error = manager.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            Divider().padding(.vertical)

            Text("Your Friends")
                .font(.headline)

            List {
                ForEach(manager.friendsEmails, id: \.self) { email in
                    HStack {
                        Text(email)
                        Spacer()
                        Button(action: {
                            removeFriendByEmail(email: email)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .onAppear {
            manager.fetchFriends()
        }
    }
    
    private func removeFriendByEmail(email: String) {
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments { snapshot, error in
                guard let document = snapshot?.documents.first else { return }
                let uid = document.documentID
                manager.removeFriend(uid: uid)
            }
    }
}

struct SocialView: View {
    @StateObject private var activityManager = ActivityManager()
    @State private var selectedCategory: ActivityCategory = .activity
    @State private var messageText: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Post Activity")
                    .font(.title2.bold())
                    .padding(.top)
                
                Picker("Category", selection: $selectedCategory) {
                    ForEach(ActivityCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                TextEditor(text: $messageText)
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    )
                    .padding(.horizontal)

                Button(action: {
                    activityManager.postActivity(category: selectedCategory.rawValue, message: messageText)
                    messageText = ""
                }) {
                    Text("Post")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(messageText.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .disabled(messageText.isEmpty)

                if let error = activityManager.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Spacer()
            }
        }
    }
}

struct SocialView_Previews: PreviewProvider {
    static var previews: some View {
        SocialView()
    }
}
