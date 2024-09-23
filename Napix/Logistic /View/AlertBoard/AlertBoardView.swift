import SwiftUI

struct AlertView: View {
    @StateObject private var viewModel = RouteViewModel()
    @State private var showingError = false
    @State private var isShowingAddAlertView = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Segmented Picker
                Picker("Alert Type", selection: $viewModel.selectedSegment) {
                    Text("Active Alerts").tag(0)
                    Text("Driving Safely").tag(1)
                    Text("Scheduled").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)

                // List of filtered routes
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(viewModel.filteredRoutes) { route in
                            RouteRow(route: route) // Updated to navigate on tap
                        }
                    }
                    .padding()
                }
                .searchable(text: $viewModel.searchText, prompt: "Search Alerts")
                .navigationTitle("Alert Board")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            isShowingAddAlertView = true
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .background(
                    NavigationLink(
                        destination: AddRouteView(),
                        isActive: $isShowingAddAlertView,
                        label: { EmptyView() }
                    )
                )
            }
            .alert(isPresented: $showingError) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                viewModel.fetchRoutes() // Fetch routes when the view appears
            }
            .onChange(of: viewModel.errorMessage) { newValue in
                if newValue != nil {
                    showingError = true
                }
            }
        }
    }
}



import SwiftUI

struct MessagesView: View {
    @StateObject private var viewModel: MessageViewModel
    let vehicleNumber: String
    
    init(vehicleNumber: String) {
        self.vehicleNumber = vehicleNumber
        _viewModel = StateObject(wrappedValue: MessageViewModel(vehicleNumber: vehicleNumber))
    }
    
    var body: some View {
        List(viewModel.truckMessages.reversed(), id: \.id) { truckMessage in
            VStack(alignment: .leading) {
                Text(truckMessage.truckNumber)
                    .font(.headline)
                ForEach(truckMessage.messages.sorted(by: { $0.timestamp > $1.timestamp }), id: \.id) { message in
                    VStack(alignment: .leading) {
                        Text(message.message)
                            .font(.body)
                        Text(message.timestamp)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchMessages(for: vehicleNumber)
        }
        .navigationTitle("Messages")
    }
}



struct RouteRow: View {
    let route: Route

    var body: some View {
        NavigationLink(destination: MessagesView(vehicleNumber: route.vehicleNumber)) {
            HStack {
                Image(systemName: "bus.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .padding(.trailing, 10)

                VStack(alignment: .leading, spacing: 5) {
                    Text("\(route.fromLocation) - \(route.toLocation)")
                        .font(.headline)
                    Text(route.vehicleNumber)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(route.driverName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}





struct AddRouteView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AddRouteViewModel()
    
    @State private var selectedDriver = ""
    @State private var selectedVehicle = ""
    @State private var fromLocation = ""
    @State private var toLocation = ""
    @State private var selectedDate = Date()
    @State private var showingDriverSheet = false
    @State private var showingVehicleSheet = false
    @State private var alertMessage: String?
    @State private var showingAlert = false
    
    private var isSaveButtonEnabled: Bool {
        !selectedDriver.isEmpty && !selectedVehicle.isEmpty && !fromLocation.isEmpty && !toLocation.isEmpty
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Driver and Vehicle")) {
                    Button(action: {
                        showingDriverSheet.toggle()
                    }) {
                        HStack {
                            Text("Select Driver")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(selectedDriver.isEmpty ? "Select a driver" : selectedDriver)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .sheet(isPresented: $showingDriverSheet) {
                        SelectionSheet(title: "Select Driver", options: viewModel.drivers, selection: $selectedDriver)
                    }
                    
                    Button(action: {
                        showingVehicleSheet.toggle()
                    }) {
                        HStack {
                            Text("Select Vehicle")
                                .foregroundColor(.primary)
                            Spacer()
                            Text(selectedVehicle.isEmpty ? "Select a vehicle" : selectedVehicle)
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .sheet(isPresented: $showingVehicleSheet) {
                        SelectionSheet(title: "Select Vehicle", options: viewModel.vehicles, selection: $selectedVehicle)
                    }
                }
                
                Section(header: Text("Location")) {
                    TextField("Enter from location", text: $fromLocation)
                        .padding(.vertical, 4)
                    
                    TextField("Enter to location", text: $toLocation)
                        .padding(.vertical, 4)
                }
                
                Section(header: Text("Date and Time")) {
                    DatePicker("Departure", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                }
            }
            .navigationTitle("Add New Route")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(action: {
                    createRoute()
                }) {
                    Text("Save")
                        .foregroundColor(isSaveButtonEnabled ? .blue : .gray)
                }
                .disabled(!isSaveButtonEnabled)
            )
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Route Creation"),
                message: Text(alertMessage ?? "Unknown error"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func createRoute() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let departureTimeString = formatter.string(from: selectedDate)
        
        let departureDetails = DepartureDetails(departureTime: departureTimeString)
        
        viewModel.createRoute(
            vehicleNumber: selectedVehicle,
            driverName: selectedDriver,
            fromLocation: fromLocation,
            toLocation: toLocation,
            departureDetails: departureDetails
        ) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    alertMessage = message
                    showingAlert = true
                    presentationMode.wrappedValue.dismiss()
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }
}


struct SelectionSheet: View {
    let title: String
    let options: [String]
    @Binding var selection: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(options, id: \.self) { option in
                Button(action: {
                    selection = option
                    dismiss() // Dismiss the sheet after selection
                }) {
                    HStack {
                        Text(option)
                        Spacer()
                        if option == selection {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarItems(trailing: Button("Done") {
                dismiss() // Dismiss the sheet
            })
        }
    }
}
