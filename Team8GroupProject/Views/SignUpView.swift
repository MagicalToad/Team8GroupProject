//
//  SignUpView.swift
//  Team8GroupProject
//
//  Created by Thoene, Zachary on 4/12/25.
//


//
//  SignUpView.swift
//  Team8GroupProject
//
//  Created by Thoene, Zachary on 4/10/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @State private var logoAnimate = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var isSignedUp = false

    var body: some View {
        NavigationStack { // Make sure to wrap the view in NavigationStack
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack {
                        Spacer().frame(height: 80)
                        
                        Image("TechTouch")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 220)
                            .offset(x: logoAnimate ? 0 : -UIScreen.main.bounds.width)
                            .scaleEffect(logoAnimate ? 1 : 0.2)
                            .opacity(logoAnimate ? 1 : 0)
                            .animation(.easeInOut(duration: 0.9).delay(0.0), value: logoAnimate)
                        
                        Text("Join Us")
                            .font(.largeTitle)
                            .bold()
                            .padding(.top, 20)
                            .colorInvert()
                            .opacity(logoAnimate ? 1 : 0)
                            .animation(.easeIn(duration: 1).delay(0.3), value: logoAnimate)
                            .colorScheme(.light)
                        
                        Text("Create an account to get started.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .padding(.top, 10)
                            .colorInvert()
                            .opacity(logoAnimate ? 1 : 0)
                            .animation(.easeIn(duration: 1).delay(0.6), value: logoAnimate)
                            .colorScheme(.light)
                        
                        // Sign Up Form
                        VStack(spacing: 20) {
                            TextField("Email", text: $email)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(25)
                                .foregroundColor(.black)
                                .padding(.horizontal)
                                .autocapitalization(.none)
                                .colorScheme(.light)
                            
                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(25)
                                .foregroundColor(.black)
                                .padding(.horizontal)
                                .textContentType(.password)
                                .colorScheme(.light)
                            
                            SecureField("Confirm Password", text: $confirmPassword)
                                .padding()
                                .foregroundColor(.black)
                                .background(.white)
                                .cornerRadius(25)
                                .padding(.horizontal)
                                .textContentType(.password)
                                .colorScheme(.light)
                            
                            if !errorMessage.isEmpty {
                                Text(errorMessage)
                                    .font(.body)
                                    .foregroundColor(.red)
                                    .padding(.top, 10)
                            }
                            
                            Button(action: {
                                signUpUser(email: email, password: password)
                            }) {
                                Text("Join Now")
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .frame(maxWidth: 150)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(25)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    Spacer()
                }
                .onAppear {
                    logoAnimate = true
                }
                .navigationDestination(isPresented: $isSignedUp) {
                    ContentView()
                                }
            }
            .navigationTitle("Sign Up")
            .navigationBarBackButtonHidden(false) // Back button will show now
        }
    }
    
    // Firebase sign-up function
    func signUpUser(email: String, password: String) {
        let trimEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            return
        }

        Auth.auth().createUser(withEmail: trimEmail, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else if let user = result?.user {
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).setData([
                    "email": email
                ]) { error in
                    if let error = error {
                        print("Error writing user to Firestore: \(error.localizedDescription)")
                    } else {
                        print("User signed up and added to Firestore: \(email)")
                    }
                }
            }
        }
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}


