import SwiftUI

struct SignUpView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var companyName = ""
    
    @State private var signUpMessage = ""
    
    let networkManager = NetworkManager.shared
    
    var body: some View {
        Form {
            Section(header: Text("Sign Up Details")) {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
                TextField("Phone Number", text: $phoneNumber)
                SecureField("Password", text: $password)
                TextField("Company Name", text: $companyName)
            }
            
            Button(action: signUp) {
                Text("Sign Up")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            if !signUpMessage.isEmpty {
                Text(signUpMessage)
                    .foregroundColor(.green)
                    .padding()
            }
        }
        .navigationTitle("Sign Up")
    }
    
    func signUp() {
        let newUser = LogisticsUser(name: name, email: email, phoneNumber: phoneNumber, password: password, companyName: companyName)
        
        networkManager.signUpLogisticsUser(user: newUser) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    signUpMessage = message
                case .failure(let error):
                    signUpMessage = "Failed to sign up: \(error.localizedDescription)"
                }
            }
        }
    }
}
