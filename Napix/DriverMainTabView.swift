
import SwiftUI

struct DriverMainTabView: View {
    var body: some View {
        TabView {
                    // First tab
            ContentView()
                        .tabItem {
                            Image(systemName: "house")
                        }

                    // Second tab
            DriverProfileView()
                        .tabItem {
                            Image(systemName: "house")
                        }
                }
    }
}


struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings View")
                .font(.largeTitle)
            // Add more UI components for SettingsView here
        }
        .padding()
    }
}


#Preview {
    DriverMainTabView()
}
