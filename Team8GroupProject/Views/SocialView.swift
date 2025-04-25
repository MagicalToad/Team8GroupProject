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


struct UserModel: Identifiable, Codable {
    @DocumentID var id: String?
    var email: String
}

struct ActivityModel: Identifiable, Codable {
    @DocumentID var id: String?
    var userId: String
    var username: String
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


extension Notification.Name {
  static let friendsChanged = Notification.Name("friendsChanged")
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
                            NotificationCenter.default.post(name: .friendsChanged, object: nil)
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
                else {
                    NotificationCenter.default.post(name: .friendsChanged, object: nil)
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
        let uid = user.uid
        let email = user.email ?? "Unknown"
        let newActivity = ActivityModel(
                userId: uid,
                username: email,
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
                    .background(Color(.systemGray6))
                    .foregroundColor(.black)
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

struct MainSocialFeedView: View {
    @StateObject private var friendManager = FriendManager()
    @State private var friendUIDs: [String] = []
    @State private var activities: [ActivityModel] = []
    
    private let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            NavigationLink(destination: AddFriendView()) {
                
                HStack {
                    
                    Image(systemName: "plus.circle.fill")
                    Text("Add Friends")
                }
                .font(.headline)
                .padding(10)
                .foregroundColor(.blue)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                
                
                NavigationLink(destination: MyActivityView()) {
                                    Image(systemName: "person.crop.square")
                                        .font(.title2)
                                        .padding(10)
                                        .foregroundColor(.blue)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(8)
                                }
                .background(Color(.systemGray6))
            }
            .background(Color(.systemGray6))
            
            .padding(.horizontal)
            
            
            List(activities.sorted(by: { $0.timestamp > $1.timestamp })) { activity in
                VStack(alignment: .leading, spacing: 6) {
                    Text(activity.username)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(activity.category)
                        .font(.headline)
                        .foregroundColor(.black)
                    Text(activity.message)
                        .font(.body)
                        .foregroundColor(.black)
                    Text(activity.timestamp, style: .time)
                        .font(.caption)
                        .foregroundColor(.black)
                }
                .padding(.vertical, 6)
                
            }

            NavigationLink(destination: SocialView()) {
                Text("Add Post")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(15)
            }
            .background(Color(.systemGray6))
        }
        .foregroundColor(Color(.systemGray6))
        .background(Color(.systemGray6))
        .onAppear { fetchFriendUIDsAndPosts() }
    }
        


    private func fetchFriendUIDsAndPosts() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(uid).collection("friends").getDocuments { snapshot, error in
            guard let documents = snapshot?.documents else { return }
            friendUIDs = documents.compactMap { $0.data()["uid"] as? String }

            guard !friendUIDs.isEmpty else {
                activities = []
                return
            }

            db.collection("activities")
                .whereField("userId", in: friendUIDs)
                .order(by: "timestamp", descending: true)
                .addSnapshotListener { snapshot, error in
                    if let snapshot = snapshot {
                        activities = snapshot.documents.compactMap {
                            try? $0.data(as: ActivityModel.self)
                        }
                    }
                }
        }
    }
}


struct SocialView: View {
    @StateObject private var activityManager = ActivityManager()
    @State private var selectedCategory: ActivityCategory = .activity
    @State private var messageText: String = ""
    @State private var showPostAlert = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                Picker("Category", selection: $selectedCategory) {
                    ForEach(ActivityCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding()
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
                    showPostAlert = true
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
        .navigationTitle("Post Activity")
        .alert("Activity Posted!", isPresented: $showPostAlert) {
            Button("OK") {
                dismiss()
            }
        }
    }
        
}

struct MyActivityView: View {
    @State private var activities: [ActivityModel] = []
    private let db = Firestore.firestore()

    var body: some View {
        List(activities.sorted(by: { $0.timestamp > $1.timestamp })) { activity in
            VStack(alignment: .leading, spacing: 6) {
                Text(activity.category)
                    .font(.headline)
                Text(activity.message)
                    .font(.body)
                Text(activity.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 6)
        }
        .listStyle(PlainListStyle())
        .navigationTitle("My Activity")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: fetchMyActivities)
    }

    private func fetchMyActivities() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("activities")
            .whereField("userId", isEqualTo: uid)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let snapshot = snapshot {
                    activities = snapshot.documents.compactMap {
                        try? $0.data(as: ActivityModel.self)
                    }
                }
            }
    }
}


struct SocialView_Previews: PreviewProvider {
    static var previews: some View {
        SocialView()
    }
}
