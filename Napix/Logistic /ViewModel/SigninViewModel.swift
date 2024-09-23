import SwiftUI

class SignInViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String?
    @Published var isAuthenticated: Bool = false
    @Published var userRole: String?  // To track user role from backend
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required"
            return
        }
        
        NetworkManager.shared.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let (token, role)):
                    self.userRole = role
                    self.isAuthenticated = true
                    
                    // Save token and role if needed for future use
                    UserDefaults.standard.set(token, forKey: "authToken")
                    
                    // Add any additional logic based on role, like navigating to different views
                    if role == "driver" {
                        // Navigate to driver-specific view
                    } else if role == "logistics" {
                        // Navigate to logistics-specific view
                    }
                    
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
