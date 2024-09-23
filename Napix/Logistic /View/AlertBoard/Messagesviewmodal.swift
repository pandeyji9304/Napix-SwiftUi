import Foundation
import Combine

class MessageViewModel: ObservableObject {
    @Published var truckMessages: [TruckMessage] = []
    @Published var error: String?
    
    private var timer: AnyCancellable?
    
    init(vehicleNumber: String) {
        fetchMessages(for: vehicleNumber) // Initial fetch
        setupTimer(for: vehicleNumber)
    }
    
    // Set up a timer for periodic fetching
    private func setupTimer(for vehicleNumber: String) {
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchMessages(for: vehicleNumber)
            }
    }
    
    // Function to fetch truck messages
    func fetchMessages(for vehicleNumber: String) {
        NetworkManager.shared.fetchMessages(for: vehicleNumber) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let messages):
                    self.truckMessages = messages
                    print("Fetched messages: \(messages)") // Debugging line
                case .failure(let error):
                    self.error = error.localizedDescription
                }
            }
        }
    }
}
