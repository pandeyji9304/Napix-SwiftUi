import Combine
import Foundation

class ProfileViewModel: ObservableObject {
    @Published var userProfile: UserProfile?
    @Published var isLoading = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchUserProfile() {
        isLoading = true
        NetworkManager.shared.fetchUserProfile { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let profile):
                    self?.userProfile = profile
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
}
