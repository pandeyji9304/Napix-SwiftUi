import Combine
import SwiftUI

class AddRouteViewModel: ObservableObject {
    @Published var drivers: [String] = []
    @Published var vehicles: [String] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let networkManager = NetworkManager.shared
    
    init() {
        fetchDrivers()
        fetchVehicles()
    }
    
    func fetchDrivers() {
        guard let token = getAuthToken() else {
            print("No authentication token found.")
            return
        }
        
        networkManager.fetchDriverList(token: token)
            .map { $0.map { $0.name } }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error fetching drivers: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] driverNames in
                self?.drivers = driverNames
            })
            .store(in: &cancellables)
    }
    
    func fetchVehicles() {
        guard let token = getAuthToken() else {
            print("No authentication token found.")
            return
        }
        
        networkManager.fetchVehiclesList(token: token)
            .map { $0.map { $0.vehicleNumber } }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("Error fetching vehicles: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] vehicleNumbers in
                self?.vehicles = vehicleNumbers
            })
            .store(in: &cancellables)
    }
    
    func createRoute(vehicleNumber: String, driverName: String, fromLocation: String, toLocation: String, departureDetails: DepartureDetails, completion: @escaping (Result<String, Error>) -> Void) {
        let request = RouteCreationRequest(
            vehicleNumber: vehicleNumber,
            driverName: driverName,
            fromLocation: fromLocation,
            toLocation: toLocation,
            departureDetails: departureDetails
        )
        
        networkManager.createRoute(request: request, completion: completion)
    }
}

// Mock function for auth token
func getAuthToken() -> String? {
    return UserDefaults.standard.string(forKey: "authToken")
}
