import SwiftUI

struct DriverProfileView: View {
    @StateObject private var viewModel = DriverProfileViewModel()
    @State private var isEditing = false
    
    var body: some View {
        NavigationView {
            VStack {
                if let driverProfile = viewModel.driver {
                    Form {
                        // Profile Image Section
                        Section(header: Text("Profile Picture")) {
                            HStack {
                                Spacer()
                                VStack {
                                    Image(systemName: "person.circle.fill") // Replace with real image if available
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                    
                                    Text(driverProfile.name)
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .padding(.top, 8)
                                    
                                    Text(driverProfile.email)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Text(driverProfile.mobileNumber)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                        
                        // User Information Section
                        Section(header: Text("User Information")) {
                            NavigationLink(destination: EditProfileView(user: User(name: "John Doe", email: "john@example.com"), isEditing: .constant(true))) {
                                Label("Edit Profile", systemImage: "pencil")
                            }

                        }
                        
                        // Support Section
                        Section(header: Text("Support")) {
                            NavigationLink(destination: HelpView()) {
                                Label("Help", systemImage: "questionmark.circle")
                            }

                            NavigationLink(destination: PrivacyPolicyView()) {
                                Label("Privacy Policy", systemImage: "shield")
                            }
                        }
                        
                        // Log Out Button
                        Section {
                            Button(action: {
                                // Handle logout action
                            }) {
                                HStack {
                                    Spacer()
                                    Text("Log Out")
                                        .foregroundColor(.red)
                                    Spacer()
                                }
                            }
                        }
                    }
                } else if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else if let error = viewModel.error {
                    Text("Error: \(error.localizedDescription)")
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                viewModel.fetchDriverProfile()
            }
        }
    }
}



