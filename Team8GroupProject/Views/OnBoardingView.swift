//
//  OnBoardingView.swift
//  Team8GroupProject
//
//  Created by Chris Xiong on 3/4/25.
//

import SwiftUI

struct OnboardingView: View {
    @AppStorage("loggedIn") private var loggedIn = false // Store user state
    @State private var logoAnimate = false // Animation Logo
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                Color.black
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer().frame(height:80)
                    
                    // App Logo
                    Image("AppLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .offset(x: logoAnimate ? 0 : -UIScreen.main.bounds.width)
                        .scaleEffect(logoAnimate ? 1 : 0.2)
                        .opacity(logoAnimate ? 1 : 0)
                        .animation(.easeInOut(duration: 0.9).delay(0.0), value: logoAnimate)
                    
                    Text("Welcome!")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 20)
                        .colorInvert()
                        .opacity(logoAnimate ? 1 : 0)
                        .animation(.easeIn(duration: 1).delay(0.3), value: logoAnimate)
                    
                    Text("Track your workouts, set goals, share with friends, and stay motivated!")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 10)
                        .colorInvert()
                        .opacity(logoAnimate ? 1 : 0)
                        .animation(.easeIn(duration: 1).delay(0.6), value: logoAnimate)
                    
                    Spacer().frame(height: 40) // Spacing between text and buttons
                    
                    // Sign In and Sign Up buttons
                    VStack(spacing: 20) {
                        NavigationLink{
                            SignInView()
                        } label: {
                            Text("Sign In")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: 150)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(25)
                                .padding(.horizontal)
                        }
                        
                        NavigationLink{
                            SignUpView()
                        } label: {
                            Text("Join Us")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: 150)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(25)
                                .padding(.horizontal)
                        }
                        
                        // --- TESTING BYPASS BUTTON START ---
                        #if DEBUG
                        Button("Bypass Login (Testing)") {
                            loggedIn = true
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: 150)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(25)
                        .padding(.top, 25)
                        #endif
                    }
                    
                    Spacer()
                }
                
                // For development: links only to ContentView for now
                .navigationDestination(isPresented: $loggedIn) {
                    ContentView()
                }
            }
            .onAppear{
                logoAnimate = true
            }
        }
    }
}
#Preview {
    OnboardingView()
}
