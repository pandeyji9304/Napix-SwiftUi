
import SwiftUI

struct DriverMainTabView: View {
    var body: some View {
        TabView {
                    // First tab
            MonitorMeView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }

                    // Second tab
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
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
