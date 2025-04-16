//
//  SignInView.swift
//  Team8GroupProject
//
//  Created by Thoene, Zachary on 4/12/25.
//


//
//  SignInView.swift
//  Team8GroupProject
//
//  Created by Thoene, Zachary on 4/10/25.
//


import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @State private var logoAnimate = false
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    
    // Add a state variable to trigger navigation programmatically
    @State private var navigateToHome = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer().frame(height: 80)
                    
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .offset(x: logoAnimate ? 0 : -UIScreen.main.bounds.width)
                        .scaleEffect(logoAnimate ? 1 : 0.2)
                        .opacity(logoAnimate ? 1 : 0)
                        .animation(.easeInOut(duration: 0.9).delay(0.0), value: logoAnimate)
                    
                    Text("Sign In")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 20)
                        .colorInvert()
                        .opacity(logoAnimate ? 1 : 0)
                        .animation(.easeIn(duration: 1).delay(0.3), value: logoAnimate)
                    
                    Text("Enter your details to sign in.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 10)
                        .colorInvert()
                        .opacity(logoAnimate ? 1 : 0)
                        .animation(.easeIn(duration: 1).delay(0.6), value: logoAnimate)
                    
                    // Sign In Form
                    VStack(spacing: 20) {
                        TextField("Email", text: $email)
                            .padding()
                            .background(Color.white) // Light background with opacity
                            .cornerRadius(25)
                            .foregroundColor(.black) // Text color white for better visibility
                            .padding(.horizontal)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white) // Light background with opacity
                            .cornerRadius(25)
                            .foregroundColor(.black) // Text color white for better visibility
                            .padding(.horizontal)
                            .textContentType(.password)
                        
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.body)
                                .foregroundColor(.red)
                                .padding(.top, 10)
                        }
                        
                        Button(action: {
                            signInUser(email: email, password: password)
                        }) {
                            Text("Sign In")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: 150)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(25)
                                .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                }
                .onAppear {
                    logoAnimate = true
                }
                
                // Programmatic navigation to ContentView after successful login
                .navigationDestination(isPresented: $navigateToHome) {
                    ContentView()
                }
            }
        }
    }
    
    // Firebase sign-in function
    func signInUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                // On successful login, set navigateToHome to true
                navigateToHome = true
                print("User signed in: \(result?.user.email ?? "")")
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}

