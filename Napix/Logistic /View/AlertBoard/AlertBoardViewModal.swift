import Foundation
import Combine

class RouteViewModel: ObservableObject {
    @Published var routes: [Route] = []
    @Published var searchText = ""
    @Published var selectedSegment = 0
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        fetchRoutes()
    }
    
    func fetchRoutes() {
        NetworkManager.shared.fetchRoutes { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let routes):
                    self?.routes = routes
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // Filtered routes based on search text, vehicle number, driver name, fromLocation, toLocation, and segment selection
    var filteredRoutes: [Route] {
        let filteredByText = routes.filter { route in
            searchText.isEmpty ||
            route.driverName.localizedCaseInsensitiveContains(searchText) ||
            route.vehicleNumber.localizedCaseInsensitiveContains(searchText) ||
            route.fromLocation.localizedCaseInsensitiveContains(searchText) ||
            route.toLocation.localizedCaseInsensitiveContains(searchText)
        }
        
        switch selectedSegment {
        case 1: // Driving Safely
            return filteredByText.filter { $0.status == "driving safely" }
        case 2: // Scheduled
            return filteredByText.filter { $0.status == "scheduled" }
        default: // Active Alerts
            return filteredByText.filter { $0.status == "active alerts" }
        }
    }
}
