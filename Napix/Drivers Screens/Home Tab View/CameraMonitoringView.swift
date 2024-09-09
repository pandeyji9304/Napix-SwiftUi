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
                        CameraView()
                            .frame(width: 300, height: 300)
                            .cornerRadius(10)
                            .transition(.opacity)
                        Text("Camera open")
                    }

                    Button(action: {
                        showAlert = true
                    }) {
                        Text("End Monitoring")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
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
        .navigationBarBackButtonHidden(true) // Ensure back button is hidden on the black screen
        .navigationBarHidden(isBlackScreen) // Hide navigation bar when black screen is active
    }
}


struct CameraMonitoringView_Previews: PreviewProvider {
    static var previews: some View {
        CameraMonitoringView()
    }
}
