import Combine
import Foundation

class DriverProfileViewModel: ObservableObject {
    @Published var driver: Driver?
    @Published var isLoading = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchDriverProfile() {
        isLoading = true
        NetworkManager.shared.fetchDriverProfile { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let driver):
                    self?.driver = driver
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    
    func updateDriverProfile(driver: Driver) {
           isLoading = true
           NetworkManager.shared.updateDriverProfile(driver: driver) { [weak self] result in
               DispatchQueue.main.async {
                   self?.isLoading = false
                   switch result {
                   case .success:
                       self?.fetchDriverProfile()
                   case .failure(let error):
                       self?.error = error
                   }
               }
           }
       }
}

