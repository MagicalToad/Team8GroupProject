import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class PostViewModel: ObservableObject {
    @Published var posts: [Post] = []
    
    private var db = Firestore.firestore()
    
    // Fetch posts from Firestore
    func fetchPosts() {
        guard let userEmail = Auth.auth().currentUser?.email else {
            return
        }
        
        db.collection("posts")
            .whereField("userEmail", isEqualTo: userEmail)
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snapshot, error in
                if let error = error {
                    print("Error fetching posts: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No posts found.")
                    return
                }
                
                self?.posts = documents.map { document -> Post in
                    let data = document.data()
                    let id = document.documentID
                    let category = data["category"] as? String ?? "General"
                    let message = data["message"] as? String ?? ""
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    let userEmail = data["userEmail"] as? String ?? ""
                    
                    return Post(id: id, category: category, message: message, timestamp: timestamp, userEmail: userEmail)
                }
            }
    }
    
    // Add new post
    func addPost(category: String, message: String) {
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        
        db.collection("posts").addDocument(data: [
            "category": category,
            "message": message,
            "timestamp": Timestamp(),
            "userEmail": userEmail
        ]) { [weak self] error in
            if let error = error {
                print("Error adding post: \(error.localizedDescription)")
            } else {
                self?.fetchPosts()  // Fetch posts after adding new one
            }
        }
    }
}
