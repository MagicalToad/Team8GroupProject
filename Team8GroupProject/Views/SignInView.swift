import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @AppStorage("loggedIn") private var loggedIn = false   // ← drive navigation
    @State private var logoAnimate = false
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""

    var body: some View {
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
                    .animation(.easeInOut(duration: 0.9), value: logoAnimate)

                Text("Sign In")
                    .font(.largeTitle).bold()
                    .padding(.top, 20)
                    .colorInvert()
                    .opacity(logoAnimate ? 1 : 0)
                    .animation(.easeIn(duration: 1).delay(0.3), value: logoAnimate)

                Text("Enter your details to sign in.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .colorInvert()
                    .opacity(logoAnimate ? 1 : 0)
                    .animation(.easeIn(duration: 1).delay(0.6), value: logoAnimate)

                VStack(spacing: 20) {
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                        .padding(.horizontal)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                        .padding(.horizontal)
                        .textContentType(.password)

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }

                    Button {
                        signInUser(email: email, password: password)
                    } label: {
                        Text("Sign In")
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: 150)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(25)
                    }
                }

                Spacer()
            }
            .onAppear { logoAnimate = true }
        }
    }

    private func signInUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                // flip the AppStorage key — this will automatically
                // rebuild your App's WindowGroup to show ContentView()
                loggedIn = true
            }
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
