import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModel()

    var body: some View {
        NavigationView {
            VStack {
                Text("Sign In")
                    .font(.largeTitle)
                    .padding()
                
                TextField("Email", text: $viewModel.email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                Button(action: viewModel.signIn) {
                    Text("Sign In")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                // Conditionally navigating based on userRole
                if let userRole = viewModel.userRole {
                    if userRole == "driver" {
                        NavigationLink(
                            destination: DriverMainTabView(), // Your driver-specific view
                            isActive: $viewModel.isAuthenticated,
                            label: { EmptyView() }
                        )
                    } else if userRole == "logistics_head" {
                        NavigationLink(
                            destination: LogisticMainTabView(), // Your logistics-specific view
                            isActive: $viewModel.isAuthenticated,
                            label: { EmptyView() }
                        )
                    }
                }
            }
            .padding()
        }
    }
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
