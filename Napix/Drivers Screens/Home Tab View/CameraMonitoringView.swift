import SwiftUI
import AVFoundation

struct CameraMonitoringView: View {
    @State private var showAlert = false
    @State private var isSplashView = false
    @State private var isSharePlayActive = true
    @State private var isBlackScreen = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    Spacer() // Add space to push the content down
                    
                    if isSplashView {
                        // Splash View
                        VStack {
                            Image("FaceDetected")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .overlay(
                                    Text("Splash Image")
                                        .foregroundColor(.white)
                                        .font(.headline)
                                )
                                .transition(.opacity)
                        }
                    } else {
                        // Camera View
                        ContentView()
                            .frame(width: 300, height: 300)
                            .cornerRadius(10)
                            .transition(.opacity)
                        Text("Camera open")
                    }

                    Spacer() // Add space before the button
                        .frame(height: 130)
                    // "End Monitoring" Button, styled to match "Start Monitoring"
                    Button(action: {
                        showAlert = true
                    }) {
                        Text("End Monitoring")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: 50)
                            .background(Color.red)
                            .cornerRadius(12)
                            .padding(.horizontal, 40) // Same padding as in MonitorMeView
                            .padding(.bottom, 40) // Increase bottom padding to push the button lower
                    }
                    .buttonStyle(PlainButtonStyle())
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Confirm End Monitoring"),
                            message: Text("Are you sure you want to end monitoring?"),
                            primaryButton: .default(Text("Confirm"), action: {
                                presentationMode.wrappedValue.dismiss()
                            }),
                            secondaryButton: .cancel(Text("Cancel"))
                        )
                    }

                    Spacer() // Add space below the button
                }
                .navigationTitle("Monitoring")
                .navigationBarBackButtonHidden(true) // Hide back button
                .navigationBarHidden(isBlackScreen) // Conditionally hide navigation bar

                // Toolbar items
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                isSplashView.toggle()
                                isSharePlayActive.toggle()
                            }
                        }) {
                            Image(systemName: isSharePlayActive ? "shareplay" : "shareplay.slash")
                                .foregroundColor(.blue)
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            withAnimation {
                                isBlackScreen.toggle()
                            }
                        }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }

            if isBlackScreen {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        Text("Black Screen")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .bold()
                    )
                    .onTapGesture {
                        withAnimation {
                            isBlackScreen = false
                        }
                    }
                    .transition(.opacity)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(isBlackScreen)
    }
}

#Preview {
    CameraMonitoringView()
}
