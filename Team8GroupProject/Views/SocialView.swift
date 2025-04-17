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
    var message: String
    var timestamp: Date
}


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

            Button(action: {
                manager.addFriendByEmail()
            }) {
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
                            // Look up UID by email and remove it
                            self.removeFriendByEmail(email: email, manager: manager)
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

    private func removeFriendByEmail(email: String, manager: FriendManager) {
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

