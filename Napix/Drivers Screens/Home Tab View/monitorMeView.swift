import SwiftUI
import SocketIO

struct ContentView: View {
    @State private var vehicleNumber: String = ""
    @State private var message: String = ""
    @State private var messages: [String] = []
    @State private var showMessageSection = false
    @State private var isSocketConnected = false
    @State private var showVehicleInputModal = false
    @State private var isMonitoringStarted = false
    
    private var manager: SocketManager
    private var socket: SocketIOClient
    
    init() {
        let baseURL = "https://napixbackend-2.onrender.com"
        let token = UserDefaults.standard.string(forKey: "authToken") ?? ""
        
        self.manager = SocketManager(
            socketURL: URL(string: baseURL)!,
            config: [
                .log(true),
                .compress,
                .extraHeaders(["Authorization": "Bearer \(token)"]),
                .forceWebsockets(true)
            ]
        )
        self.socket = manager.defaultSocket
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if !isMonitoringStarted {
                    // Vehicle Input / Initial Screen
                    VStack {
                        Image("MonitorMeImage") // Replace with your image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                            .padding()
                        
                        Button("Start Monitoring") {
                            showVehicleInputModal = true
                        }
                        .padding()
                        .font(.title)
                        .buttonStyle(.borderedProminent)
                    }
                    .sheet(isPresented: $showVehicleInputModal) {
                        VStack {
                            Text("Enter Vehicle Number")
                                .font(.headline)
                                .padding()
                            
                            TextField("Vehicle Number", text: $vehicleNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding()
                            
                            Button("Connect") {
                                connectToSocket()
                            }
                            .padding()
                        }
                        .padding()
                    }
                } else {
                    // Monitoring Screen
                    VStack {
                        Text("Connected to: \(vehicleNumber)")
                            .font(.title)
                            .padding()
                        
                        TextField("Type a message", text: $message)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                        
                        Button("Send Message") {
                            sendMessage()
                        }
                        .padding()
                        
                        List(messages, id: \.self) { msg in
                            Text(msg)
                        }
                        
                        HStack {
                            Button("End Route") {
                                endRoute()
                            }
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(10)
                            
                            Button("Disconnect") {
                                disconnect()
                            }
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                        .padding()
                        
                        NavigationLink(destination: CameraMonitoringView()) {
                            Text("Go to Camera Monitoring")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                    .padding()
                    .navigationTitle("Driver Communication")
                }
            }
            .onAppear {
                configureSocket()
            }
        }
    }
    
    private func configureSocket() {
        socket.on(clientEvent: .connect) { _, _ in
            DispatchQueue.main.async {
                self.isSocketConnected = true
                print("Socket connected")
            }
        }
        
        socket.on(clientEvent: .disconnect) { _, _ in
            DispatchQueue.main.async {
                self.isSocketConnected = false
                print("Socket disconnected")
            }
        }
        
        socket.on(clientEvent: .error) { data, _ in
            if let error = data.first as? String {
                DispatchQueue.main.async {
                    print("Socket error:", error)
                }
            }
        }
        
        socket.on("message") { data, _ in
            if let message = data[safe: 1] as? String {
                DispatchQueue.main.async {
                    self.messages.append("Server: \(message)")
                    print("Received message: \(message)")
                }
            }
        }
        
        socket.connect()
    }
    
    private func connectToSocket() {
        guard !vehicleNumber.isEmpty else {
            print("Vehicle number is empty.")
            return
        }

        if !isSocketConnected {
            // Connect the socket and join room in a single step
            socket.once(clientEvent: .connect) { _, _ in
                DispatchQueue.main.async {
                    self.joinRoom() // Join the room immediately after connecting
                }
            }
            socket.connect() // Connect socket
        } else {
            joinRoom() // If already connected, just join the room
        }
    }
    
    private func joinRoom() {
        if isSocketConnected {
            socket.emit("joinRoom", vehicleNumber)
            print("Emitted joinRoom with vehicle number: \(vehicleNumber)")
            self.isMonitoringStarted = true
            self.showVehicleInputModal = false
        } else {
            print("Socket is not connected.")
        }
    }
    
    private func sendMessage() {
        guard !message.isEmpty else {
            print("Message is empty.")
            return
        }
        
        if isSocketConnected {
            socket.emit("sendMessage", vehicleNumber, message)
            print("Emitted sendMessage with vehicle number: \(vehicleNumber) and message: \(message)")
            self.messages.append("You: \(message)")
            self.message = ""
        } else {
            print("Socket is not connected.")
        }
    }
    
    private func endRoute() {
        guard !vehicleNumber.isEmpty else {
            print("Vehicle number is empty.")
            return
        }
        
        if isSocketConnected {
            socket.emit("endRoute", vehicleNumber)
            print("Emitted endRoute with vehicle number: \(vehicleNumber)")
        } else {
            print("Socket is not connected.")
        }
    }
    
    private func disconnect() {
        socket.disconnect()
        print("Socket disconnected manually.")
        
        // Resetting state
        vehicleNumber = "" // Clear vehicle number
        isMonitoringStarted = false // Reset monitoring state
        showVehicleInputModal = false // Don't show the input modal
    }
}

// Safe array indexing extension remains unchanged
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
