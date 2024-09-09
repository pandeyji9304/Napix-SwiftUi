import SwiftUI

struct MonitorMeView: View {
    @State private var showAlert = false
    @State private var navigateToChildView = false // State to trigger navigation

    var body: some View {
        NavigationStack {
            VStack {
                Image("MonitorMeImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
                    .padding(.bottom, 40)

                Button(action: {
                    showAlert = true // Show the alert when button is clicked
                }) {
                    Text("Start Monitoring")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Confirm Monitoring"),
                        message: Text("Are you sure you want to start monitoring?"),
                        primaryButton: .default(Text("Confirm"), action: {
                            navigateToChildView = true // Trigger navigation to child view
                        }),
                        secondaryButton: .cancel(Text("Cancel"))
                    )
                }

                // Navigation to CameraMonitoringView when `navigateToChildView` is true
                NavigationLink(
                    destination: CameraMonitoringView(),
                    isActive: $navigateToChildView
                ) {
                    EmptyView() // Hidden view to trigger navigation
                }
            }
            .navigationTitle("Monitor Me")
            
        }
    }
}



#Preview {
    MonitorMeView()
}
