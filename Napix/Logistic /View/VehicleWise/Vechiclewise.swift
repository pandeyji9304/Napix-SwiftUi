//import SwiftUI
//import Combine
//
//// Define the vehicle data model
//
//
//struct Vehiclewise: View {
//    @StateObject private var networkManager = NetworkManager.shared
//    @State private var searchText = ""
//    @State private var showAddVehicleModal = false
//    @State private var newVehicleNumber = ""
//    
//    // Filtered alerts based on searchText
//    var filteredAlerts: [VehicleAlert] {
//        if searchText.isEmpty {
//            return networkManager.vehicleAlerts
//        } else {
//            return networkManager.vehicleAlerts.filter { $0.vehicleNumber.localizedCaseInsensitiveContains(searchText) }
//        }
//    }
//
//    var body: some View {
//        NavigationView {
//            List {
//                ForEach(filteredAlerts) { alert in
//                    NavigationLink(destination: VehicleDetailView(vehicle: alert)) {
//                        HStack {
//                            Image(systemName: "car.fill")  // Add system image here
//                                .padding(.trailing, 8)      // Add spacing between image and text
//                            Text(alert.vehicleNumber)
//                                .font(.body)
//                                .foregroundColor(.primary)  // Default iOS text color
//                        }
//                    }
//                }
//            }
//            .searchable(text: $searchText, prompt: "Search Vehicle Numbers")
//            .navigationTitle("Vehicle Wise")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(action: {
//                        showAddVehicleModal.toggle()
//                    }) {
//                        Image(systemName: "plus")
//                            .foregroundColor(.blue)
//                    }
//                }
//            }
//            .sheet(isPresented: $showAddVehicleModal) {
//                AddVehicleView(
//                    newVehicleNumber: $newVehicleNumber,
//                    onSave: { vehicleNumber in
//                        if !vehicleNumber.isEmpty {
//                            // Handle saving new vehicle here
//                            // (You would typically post to the server here)
//                            newVehicleNumber = "" // Clear the input field after saving
//                        }
//                        showAddVehicleModal = false
//                    }
//                )
//            }
//            .onAppear {
//                networkManager.fetchVehicles()
//            }
//        }
//    }
//}
//
//struct VehicleDetailView: View {
//    let vehicle: VehicleAlert
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 20) {
//            Text("Vehicle Number:")
//                .font(.headline)
//            Text(vehicle.vehicleNumber)
//                .font(.title2)
//                .fontWeight(.semibold)
//            
//            // Add more details here if needed
//            Spacer()
//        }
//        .padding()
//        .navigationTitle("Vehicle Details")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}
//
//struct AddVehicleView: View {
//    @Binding var newVehicleNumber: String
//    let onSave: (String) -> Void
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                Section(header: Text("Add New Vehicle")) {
//                    TextField("Enter vehicle number", text: $newVehicleNumber)
//                }
//            }
//            .navigationTitle("Add Vehicle")
//            .navigationBarTitleDisplayMode(.inline)
//            .navigationBarItems(
//                leading: Button("Cancel") {
//                    newVehicleNumber = "" // Clear the input field when canceled
//                    onSave("") // Clear the new vehicle number if modal is closed without saving
//                },
//                trailing: Button("Save") {
//                    onSave(newVehicleNumber)
//                }
//                .disabled(newVehicleNumber.isEmpty) // Disable the button if input field is empty
//            )
//        }
//    }
//}

import SwiftUI
import Combine


struct Vehiclewise: View {
    @StateObject private var networkManager = NetworkManager.shared
    @State private var searchText = ""
    @State private var showAddVehicleModal = false
    @State private var newVehicleNumber = ""
    
    // Filtered alerts based on searchText
    var filteredAlerts: [VehicleAlert] {
        if searchText.isEmpty {
            return networkManager.vehicleAlerts
        } else {
            return networkManager.vehicleAlerts.filter { $0.vehicleNumber.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(filteredAlerts) { alert in
                    NavigationLink(destination: VehicleDetailView(vehicle: alert)) {
                        HStack {
                            Image(systemName: "car.fill")  // Add system image here
                                .padding(.trailing, 8)      // Add spacing between image and text
                            Text(alert.vehicleNumber)
                                .font(.body)
                                .foregroundColor(.primary)  // Default iOS text color
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search Vehicle Numbers")
            .navigationTitle("Vehicle Wise")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showAddVehicleModal.toggle()
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showAddVehicleModal) {
                AddVehicleView(
                    newVehicleNumber: $newVehicleNumber,
                    onSave: { _ in
                        showAddVehicleModal = false
                        networkManager.fetchVehicles() // Refresh the list after adding a vehicle
                    }
                )
                .environmentObject(networkManager)
            }
            .onAppear {
                networkManager.fetchVehicles()
            }
        }
    }
}


struct VehicleDetailView: View {
    let vehicle: VehicleAlert
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Vehicle Number:")
                .font(.headline)
            Text(vehicle.vehicleNumber)
                .font(.title2)
                .fontWeight(.semibold)
            
            // Add more details here if needed
            Spacer()
        }
        .padding()
        .navigationTitle("Vehicle Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AddVehicleView: View {
    @Binding var newVehicleNumber: String
    @EnvironmentObject var networkManager: NetworkManager
    let onSave: (String) -> Void

    @State private var isSaving = false
    @State private var saveError: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add New Vehicle")) {
                    TextField("Enter vehicle number", text: $newVehicleNumber)
                }
                
                if isSaving {
                    ProgressView()
                }
                
                if let saveError = saveError {
                    Text(saveError)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Add Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    newVehicleNumber = "" // Clear the input field when canceled
                    onSave("") // Clear the new vehicle number if modal is closed without saving
                },
                trailing: Button("Save") {
                    saveVehicle()
                }
                .disabled(newVehicleNumber.isEmpty) // Disable the button if input field is empty
            )
        }
    }
    
    private func saveVehicle() {
        isSaving = true
        networkManager.addVehicle(vehicleNumber: newVehicleNumber) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success(let message):
                    print(message) // Handle success (e.g., show a confirmation alert)
                    newVehicleNumber = "" // Clear the input field after saving
                    onSave(newVehicleNumber) // Close the modal
                case .failure(let error):
                    saveError = error.localizedDescription // Show error message
                }
            }
        }
    }
}
