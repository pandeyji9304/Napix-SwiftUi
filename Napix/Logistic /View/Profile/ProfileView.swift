import SwiftUI
import Combine

// MARK: - Profile View (Parent)
struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isEditing = false
    
    var body: some View {
        NavigationStack {
            List {
                if let userProfile = viewModel.userProfile {
                    // Profile Image Section (Header Style)
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill") // Placeholder image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                        
                        Text(userProfile.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(userProfile.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical)
                    .listRowInsets(EdgeInsets()) // Clean look like the iOS Settings app
                    
                    // User Information Section
                    Section(header: Text("USER INFORMATION")) {
                        NavigationLink(destination: EditProfileView(user: User(name: userProfile.name, email: userProfile.email), isEditing: $isEditing)) {
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                                Text("Edit Profile")
                            }
                        }
                        
                        NavigationLink(destination: MyDrivers()) {
                            HStack {
                                Image(systemName: "car")
                                    .foregroundColor(.blue)
                                Text("My Drivers")
                            }
                        }
                    }
                    
                    // Support Section
                    Section(header: Text("SUPPORT")) {
                        NavigationLink(destination: HelpView()) {
                            HStack {
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(.blue)
                                Text("Help")
                            }
                        }
                        
                        NavigationLink(destination: PrivacyPolicyView()) {
                            HStack {
                                Image(systemName: "shield")
                                    .foregroundColor(.blue)
                                Text("Privacy Policy")
                            }
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
                } else if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                } else if let error = viewModel.error {
                    HStack {
                        Spacer()
                        Text("Error: \(error.localizedDescription)")
                        Spacer()
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarBackButtonHidden(true)
            .onAppear {
                viewModel.fetchUserProfile()
            }
        }
    }
}



// MARK: - My Drivers (Child)
struct MyDrivers: View {
    @StateObject private var networkManager = NetworkManager.shared
    @State private var searchText = ""
    @State private var showAddDriverModal = false
    @State private var newDriverName = ""
    @State private var newDriverNumber = ""
    @State private var newDriverEmail = ""
    
    // Filtered alerts based on searchText
    var filteredDriver: [Driver] {
        if searchText.isEmpty {
            return networkManager.driver
        } else {
            return networkManager.driver.filter { $0.mobileNumber.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        List {
            ForEach(filteredDriver) { alert in
                NavigationLink(destination: DriverDetailView(driver: alert)) {
                    VStack{
                        HStack {
                            Image(systemName: "car.fill")
                                .padding(.trailing, 8)
                            Text(alert.name)
                                .font(.body)
                                .foregroundColor(.primary)
                        }
                        Text(alert.mobileNumber)
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search Drivers")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showAddDriverModal.toggle()
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
        }
        .sheet(isPresented: $showAddDriverModal) {
            AddDriverView(
                newDriverName: $newDriverName,
                newDriverNumber: $newDriverNumber,
                newDriverEmail: $newDriverEmail,
                onSave: { _,_,_  in
                    showAddDriverModal = false
                    networkManager.fetchDriver() // Refresh the list after adding a vehicle
                }
            )
            .environmentObject(networkManager)
        }
        .onAppear {
            networkManager.fetchDriver()
        }
    }
}

// MARK: - Driver Detail View (Child)
struct DriverDetailView: View {
    let driver: Driver
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Driver ")
                .font(.headline)
            Text(driver.name)
                .font(.title2)
                .fontWeight(.semibold)
            Text(driver.mobileNumber)
                .font(.title2)
                .fontWeight(.semibold)
            Text(driver.email)
                .font(.title2)
                .fontWeight(.semibold)
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Add Driver View (Child)
struct AddDriverView: View {
    @Binding var newDriverName: String
    @Binding var newDriverNumber: String
    @Binding var newDriverEmail: String
    
    @EnvironmentObject var networkManager: NetworkManager
    let onSave: (String,String,String) -> Void

    @State private var isSaving = false
    @State private var saveError: String?

    var body: some View {
        Form {
            Section(header: Text("Add New Driver")) {
                TextField("Enter Driver name", text: $newDriverName)
                TextField("Enter Driver number", text: $newDriverNumber)
                TextField("Enter Driver email", text: $newDriverEmail)
            }
            
            if isSaving {
                ProgressView()
            }
            
            if let saveError = saveError {
                Text(saveError)
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Add Driver")
        .navigationBarItems(
            leading: Button("Cancel") {
                newDriverName = ""
                newDriverNumber = ""
                newDriverEmail = ""
                onSave("", "", "")
            },
            trailing: Button("Save") {
                saveDriver()
            }
            .disabled(newDriverName.isEmpty || newDriverNumber.isEmpty)
        )
    }
    
    private func saveDriver() {
        isSaving = true
        networkManager.addDriver(name: newDriverName, mobileNumber: newDriverNumber, email:newDriverEmail) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success(let message):
                    print(message)
                    newDriverName = ""
                    newDriverNumber = ""
                    onSave(newDriverName, newDriverNumber, newDriverEmail)
                case .failure(let error):
                    saveError = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - Help View (Child)
struct HelpView: View {
    var body: some View {
        Text("Help")
            .navigationTitle("Help")
    }
}

// MARK: - Privacy Policy View (Child)
struct PrivacyPolicyView: View {
    var body: some View {
        Text("Privacy Policy")
            .navigationTitle("Privacy Policy")
    }
}

// MARK: - Edit Profile View (Child)
struct EditProfileView: View {
    @Binding var isEditing: Bool
    var user: User

    @State private var name: String
    @State private var email: String

    init(user: User, isEditing: Binding<Bool>) {
        self.user = user
        self._isEditing = isEditing
        self._name = State(initialValue: user.name)
        self._email = State(initialValue: user.email)
    }

    var body: some View {
        Form {
            Section(header: Text("Edit Profile Information")) {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
            }

            Button(action: {
                isEditing = false
                // Save action here
            }) {
                Text("Save Changes")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarItems(trailing: Button("Cancel") {
            isEditing = false
        })
    }
}

// MARK: - User Model
struct User {
    var name: String
    var email: String
}
