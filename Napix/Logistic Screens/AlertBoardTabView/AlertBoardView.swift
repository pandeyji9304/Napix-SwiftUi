import SwiftUI

struct AlertView: View {
    @State private var searchText = ""
    @State private var selectedSegment = 0
    @State private var showingAddAlertSheet = false
    // Function to filter alerts based on search text and segment selection
    private var filteredAlerts: [AlertData] {
        let filteredByText = alerts.filter { alert in
            searchText.isEmpty || alert.title.localizedCaseInsensitiveContains(searchText)
        }
        switch selectedSegment {
        case 1: // Info
            return filteredByText.filter { $0.type == .info }
        case 2: // Critical
            return filteredByText.filter { $0.type == .critical }
        default:
            return filteredByText
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                // Segmented Control
                Picker("Alert Type", selection: $selectedSegment) {
                    Text("All").tag(0)
                    Text("Info").tag(1)
                    Text("Critical").tag(2)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                // Alert List with Search Bar
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(filteredAlerts) { alert in
                            AlertRow(alert: alert)
                        }
                    }
                    .padding()
                }
            }
            .searchable(text: $searchText, prompt: "Search Alerts")
            .navigationTitle("Alert Board")
            .navigationBarItems(trailing:
                HStack {
                    Image(systemName: "plus")
                        .onTapGesture {
                            showingAddAlertSheet.toggle()
                        }
                }
            )
            .sheet(isPresented: $showingAddAlertSheet) {
                AddAlertView()
            }
        }
    }
}

struct AlertRow: View {
    let alert: AlertData
    var body: some View {
        HStack {
            // Image
            Image(systemName: alert.imageName) // Replace `alert.imageName` with your actual image name or logic
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading) {
                Text(alert.title)
                    .font(.headline)
                Text(alert.code)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(alert.name)
                    .font(.caption)
                    .foregroundColor(.red)
            }
            Spacer()
            if alert.type == .critical {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            } else {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct AlertData: Identifiable {
    let id = UUID()
    let title: String
    let code: String
    let name: String
    let type: AlertType
    let imageName: String // Add imageName to AlertData
}

enum AlertType {
    case critical
    case info
}

let alerts = [
    AlertData(title: "New York - Toronto", code: "BR 21P 0005", name: "Ritik Kumar", type: .critical, imageName: "star.fill"),
    AlertData(title: "Los Angeles - Frenos", code: "BR 21P 0002", name: "Utsay Sharma", type: .info, imageName: "info.circle"),
    AlertData(title: "London - Hamberg", code: "BR 21P 0003", name: "Sunidhi Ratra", type: .critical, imageName: "exclamationmark.triangle.fill"),
    AlertData(title: "Paris - Geneva", code: "BR 21P 0004", name: "Tushar Mahajan", type: .info, imageName: "bell.fill")
]

struct AlertView_Previews: PreviewProvider {
    static var previews: some View {
        AlertView()
    }
}

struct AddAlertView: View {
    @Environment(\.presentationMode) var presentationMode

    @State private var title = ""
    @State private var code = ""
    @State private var name = ""
    @State private var type: AlertType = .info
    @State private var imageName = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Alert Details")) {
                    TextField("Title", text: $title)
                    TextField("Code", text: $code)
                    TextField("Name", text: $name)
                    
                    Picker("Type", selection: $type) {
                        Text("Info").tag(AlertType.info)
                        Text("Critical").tag(AlertType.critical)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    TextField("Image Name", text: $imageName)
                }
                
                Button(action: {
                    // Add action to save alert
                    // For example, save the alert to a list or database
                    
                    // Dismiss the modal
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Add Alert")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Add New Alert")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
