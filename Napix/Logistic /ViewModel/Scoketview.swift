//import SwiftUI
//
//struct SocketView: View {
//    @StateObject var viewModel: SocketViewModel
//    @State private var newMessage: String = ""
//    var vehicleNumber: String
//    
//    var body: some View {
//        VStack {
//            // Show connection status
//            Text(viewModel.statusMessage)
//                .foregroundColor(viewModel.statusMessage.contains("Error") ? .red : .green)
//                .padding()
//
//            // Display messages
//            List(viewModel.messages, id: \.self) { message in
//                Text(message)
//            }
//            
//            // Input for new message
//            HStack {
//                TextField("Enter message", text: $newMessage)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                
//                Button(action: {
//                    viewModel.sendMessage(vehicleNumber: vehicleNumber, message: newMessage)
//                    newMessage = ""  // Clear the input
//                }) {
//                    Text("Send")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                }
//            }
//            .padding()
//        }
//        .onAppear {
//            viewModel.connect()
//            viewModel.joinRoom(vehicleNumber: vehicleNumber)
//            viewModel.getMessages(vehicleNumber: vehicleNumber)
//        }
//        .onDisappear {
//            viewModel.disconnect()
//        }
//    }
//}
