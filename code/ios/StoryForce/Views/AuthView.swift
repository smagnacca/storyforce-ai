import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var company = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Logo
                    VStack(spacing: 10) {
                        Image(systemName: "book.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        Text("StoryForce")
                            .font(.title)
                            .fontWeight(.bold)
                        Text("AI-powered storytelling for sales")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 30)

                    // Segmented Control
                    Picker("Auth Mode", selection: $isLogin) {
                        Text("Sign In").tag(true)
                        Text("Sign Up").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    // Form Fields
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)

                        if !isLogin {
                            TextField("First Name", text: $firstName)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)

                            TextField("Last Name", text: $lastName)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)

                            TextField("Company", text: $company)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                        }
                    }
                    .padding()

                    // Error Message
                    if let error = authManager.error {
                        VStack(spacing: 8) {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text(error)
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding()
                    }

                    // Submit Button
                    Button(action: handleAuth) {
                        if authManager.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(isLogin ? "Sign In" : "Sign Up")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(authManager.isLoading || email.isEmpty || password.isEmpty)
                    .padding()

                    Spacer()

                    // Info Text
                    VStack(spacing: 8) {
                        Text(isLogin ? "Don't have an account?" : "Already have an account?")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Button(action: { isLogin.toggle() }) {
                            Text(isLogin ? "Sign Up" : "Sign In")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
            }
        }
    }

    private func handleAuth() {
        if isLogin {
            Task {
                await authManager.login(email: email, password: password)
            }
        } else {
            Task {
                await authManager.signup(
                    email: email,
                    password: password,
                    firstName: firstName,
                    lastName: lastName,
                    company: company.isEmpty ? nil : company,
                    role: nil
                )
            }
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthManager())
}
