import SwiftUI

struct Vechiclewise: View {
    @State private var searchText = ""
    
    // Sample data for the list
    let alerts = [
        "New York - Toronto",
        "Los Angeles - Fresno",
        "London - Hamburg",
        "Paris - Geneva"
    ]
    
    // Filtered alerts based on searchText
    var filteredAlerts: [String] {
        if searchText.isEmpty {
            return alerts
        } else {
            return alerts.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationStack {
            List(filteredAlerts, id: \.self) { alert in
                Text(alert)  // Render each item in the list
            }
            .searchable(text: $searchText, prompt: "Search Alerts")
            .navigationTitle("Vehicle Wise")
        }
    }
}

#Preview {
    Vechiclewise()
}

