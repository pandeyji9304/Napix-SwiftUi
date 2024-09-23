import Combine
import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidCredentials
    case parsingError
    case noDataReceived
    case serverError(message: String)
    case missingToken
    case unknownError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .invalidCredentials:
            return "Invalid email or password."
        case .parsingError:
            return "Failed to parse the server response."
        case .noDataReceived:
            return "No data received from the server."
        case .unknownError:
            return "No data found."
        case .serverError(let message):
            return message
        case .missingToken:
            return "No authentication token found."
        }
    }
}

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    @Published var vehicleAlerts: [VehicleAlert] = []
    @Published var driver: [Driver] = []
    private var cancellables = Set<AnyCancellable>()
    
     init() {}
    private func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    // MARK: - Login
    func login(email: String, password: String, completion: @escaping (Result<(String, String), Error>) -> Void) {
        guard let url = URL(string: "https://napixbackend-2.onrender.com/api/auth/login") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "email": email,
            "password": password
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.unknownError))
                return
            }
            
            // Check if the response status code is 200 (OK)
            if response.statusCode != 200 {
                completion(.failure(NetworkError.invalidCredentials))
                return
            }
            
            // Try to decode the response data
            do {
                let decoder = JSONDecoder()
                let loginResponse = try decoder.decode(LoginResponse.self, from: data)
                
                // Save token to UserDefaults
                UserDefaults.standard.set(loginResponse.token, forKey: "authToken")
                
                // Pass token and role to the completion handler
                completion(.success((loginResponse.token, loginResponse.role)))
            } catch {
                completion(.failure(NetworkError.parsingError))
            }
        }.resume()
    }
    
    // MARK: - Sign Up Logistics User
    func signUpLogisticsUser(user: LogisticsUser, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://napixbackend-2.onrender.com/api/users/signup/logistics-head") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(user)
            request.httpBody = jsonData
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noDataReceived))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                completion(.success("User created successfully"))
            } else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "An unknown error occurred"
                completion(.failure(NetworkError.serverError(message: errorMessage)))
            }
        }.resume()
    }
    
    func fetchVehicles() {
        guard let token = getAuthToken() else {
            print("No authentication token found.")
            return
        }
        
        guard let url = URL(string: "https://napixbackend-2.onrender.com/api/vehicles/getvehicles") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("Sending request to: \(url)")
        URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveSubscription: { _ in
                print("Request started")
            }, receiveOutput: { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    print("Response status code: \(httpResponse.statusCode)")
                }
                print("Raw data received: \(String(decoding: data, as: UTF8.self))")
            }, receiveCompletion: { completion in
                print("Request completed: \(completion)")
            }, receiveCancel: {
                print("Request cancelled")
            })
            .map(\.data)
            .decode(type: [VehicleAlert].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error fetching vehicles: \(error.localizedDescription)")
                } else {
                    print("Decoding succeeded")
                }
            }, receiveValue: { [weak self] vehicles in
                print("Decoded vehicles: \(vehicles)")
                self?.vehicleAlerts = vehicles
            })
            .store(in: &cancellables)
    }
    
    func fetchVehiclesList(token: String) -> AnyPublisher<[VehicleAlert], Error> {
            guard let url = URL(string: "https://napixbackend-2.onrender.com/api/vehicles/getvehicles") else {
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: [VehicleAlert].self, decoder: JSONDecoder())
                .eraseToAnyPublisher()
        }
    
    // MARK: - Add Vehicle
    func addVehicle(vehicleNumber: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = getAuthToken() else {
            completion(.failure(NetworkError.missingToken))
            return
        }
        
        guard let url = URL(string: "https://napixbackend-2.onrender.com/api/vehicles/add") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: String] = [
            "vehicleNumber": vehicleNumber
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 201 else {
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "An unknown error occurred"
                completion(.failure(NetworkError.serverError(message: errorMessage)))
                return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let message = jsonResponse?["message"] as? String {
                    completion(.success(message))
                } else {
                    completion(.failure(NetworkError.parsingError))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let url = URL(string: "https://napixbackend-2.onrender.com/api/users/profile") else {
            print("Error: Invalid URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        guard let token = getAuthToken() else {
            print("Error: Missing Auth Token")
            completion(.failure(NetworkError.missingToken))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: Network request failed with error - \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                print("Error: No data or invalid response from server")
                completion(.failure(NetworkError.serverError(message: "Failed to fetch profile data")))
                return
            }
            
            print("Response status code: \(response.statusCode)")
            print("Response data: \(String(describing: String(data: data, encoding: .utf8)))")
            
            switch response.statusCode {
            case 200:
                do {
                    let userProfile = try JSONDecoder().decode(UserProfile.self, from: data)
                    print("Success: User profile fetched successfully")
                    completion(.success(userProfile))
                } catch {
                    print("Error: Failed to decode user profile - \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case 401:
                print("Error: Invalid credentials")
                completion(.failure(NetworkError.invalidCredentials))
            case 403:
                print("Error: Access denied")
                completion(.failure(NetworkError.serverError(message: "Access denied")))
            case 404:
                print("Error: Profile not found")
                completion(.failure(NetworkError.serverError(message: "Profile not found")))
            default:
                print("Error: Server error with status code \(response.statusCode)")
                completion(.failure(NetworkError.serverError(message: "Server error with status code \(response.statusCode)")))
            }
        }.resume()
    }
    
    
    func fetchDriverProfile(completion: @escaping (Result<Driver, Error>) -> Void) {
            guard let url = URL(string: "https://napixbackend-2.onrender.com/api/drivers/driverdetail") else {
                print("Error: Invalid URL")
                completion(.failure(NetworkError.invalidURL))
                return
            }
            
            guard let token = getAuthToken() else {
                print("Error: Missing Auth Token")
                completion(.failure(NetworkError.missingToken))
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: Network request failed with error - \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data, let response = response as? HTTPURLResponse else {
                    print("Error: No data or invalid response from server")
                    completion(.failure(NetworkError.serverError(message: "Failed to fetch profile data")))
                    return
                }
                
                
                
                
                switch response.statusCode {
                case 200:
                    do {
                        let driver = try JSONDecoder().decode(Driver.self, from: data)
                        
                        completion(.success(driver))
                    } catch {
                        
                        completion(.failure(error))
                    }
                case 401:
                    print("Error: Invalid credentials")
                    completion(.failure(NetworkError.invalidCredentials))
                case 403:
                    print("Error: Access denied")
                    completion(.failure(NetworkError.serverError(message: "Access denied")))
                case 404:
                    print("Error: Profile not found")
                    completion(.failure(NetworkError.serverError(message: "Profile not found")))
                default:
                    print("Error: Server error with status code \(response.statusCode)")
                    completion(.failure(NetworkError.serverError(message: "Server error with status code \(response.statusCode)")))
                }
            }.resume()
        }

    
    
    func updateDriverProfile(driver: Driver, completion: @escaping (Result<Void, Error>) -> Void) {
            guard let url = URL(string: "https://napixbackend-2.onrender.com/api/updateDriverProfile") else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            do {
                let data = try JSONEncoder().encode(driver)
                request.httpBody = data
            } catch {
                completion(.failure(error))
                return
            }
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                completion(.success(()))
            }
            
            task.resume()
        }
        
       
    
    // MARK: - Fetch Driver

    func fetchDriver() {
        guard let token = getAuthToken() else {
            print("No authentication token found.")
            return
        }

        guard let url = URL(string: "https://napixbackend-2.onrender.com/api/drivers/getdrivers") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        print("Sending request to: \(url) with token: \(token)")

        URLSession.shared.dataTaskPublisher(for: request)
            .handleEvents(receiveSubscription: { _ in
                print("Request started")
            }, receiveOutput: { data, response in
                if let httpResponse = response as? HTTPURLResponse {
                    print("Response status code: \(httpResponse.statusCode)")
                }
                print("Raw data received: \(String(decoding: data, as: UTF8.self))")
            }, receiveCompletion: { completion in
                print("Request completed: \(completion)")
            }, receiveCancel: {
                print("Request cancelled")
            })
            .map(\.data)
            .decode(type: [Driver].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error fetching drivers: \(error.localizedDescription)")
                case .finished:
                    print("Decoding completed successfully")
                }
            }, receiveValue: { [weak self] drivers in
                print("Decoded drivers: \(drivers)")
                self?.driver = drivers// Adjust mapping based on your Driver model
            })
            .store(in: &cancellables)
    }
    
    func fetchDriverList(token: String) -> AnyPublisher<[Driver], Error> {
            guard let url = URL(string: "https://napixbackend-2.onrender.com/api/drivers/getdrivers") else {
                return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
            return URLSession.shared.dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: [Driver].self, decoder: JSONDecoder())
                .eraseToAnyPublisher()
        }


    
    
    // MARK: - Add Driver
    func addDriver(name: String,mobileNumber: String, email:String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = getAuthToken() else {
            completion(.failure(NetworkError.missingToken))
            return
        }
        
        guard let url = URL(string: "https://napixbackend-2.onrender.com/api/drivers/add-driver") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: String] = [
            "name": name,
            "mobileNumber": mobileNumber,
            "email": email
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 201 else {
                let errorMessage = String(data: data ?? Data(), encoding: .utf8) ?? "An unknown error occurred"
                completion(.failure(NetworkError.serverError(message: errorMessage)))
                return
            }
            
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let message = jsonResponse?["message"] as? String {
                    completion(.success(message))
                } else {
                    completion(.failure(NetworkError.parsingError))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    
    func fetchRoutes(completion: @escaping (Result<[Route], Error>) -> Void) {
        guard let url = URL(string: "https://napixbackend-2.onrender.com/api/routes/getroutes") else {
            print("Error: Invalid URL")
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        guard let token = getAuthToken() else {
            print("Error: Missing Auth Token")
            completion(.failure(NetworkError.missingToken))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("Starting data task to fetch routes.")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: Network request failed with error - \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else {
                print("Error: No data or invalid response from server")
                completion(.failure(NetworkError.serverError(message: "Failed to fetch routes data")))
                return
            }
            
            switch response.statusCode {
            case 200:
                do {
                    let routeResponse = try JSONDecoder().decode(RouteResponse.self, from: data)
                    let routes = routeResponse.routes
                    print("Successfully decoded routes. Count: \(routes.count)")
                    completion(.success(routes))
                } catch {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Response data string: \(jsonString)")
                    }
                    print("Error decoding data: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case 401:
                print("Error: Invalid credentials")
                completion(.failure(NetworkError.invalidCredentials))
            case 403:
                print("Error: Access denied")
                completion(.failure(NetworkError.serverError(message: "Access denied")))
            case 404:
                print("Error: Routes not found")
                completion(.failure(NetworkError.serverError(message: "Routes not found")))
            default:
                print("Error: Server error with status code \(response.statusCode)")
                completion(.failure(NetworkError.serverError(message: "Server error with status code \(response.statusCode)")))
            }
        }.resume()
    }
    
    func createRoute(request: RouteCreationRequest, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://napixbackend-2.onrender.com/api/routes/create-route") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        // Fetch the token from UserDefaults
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("No auth token found.")
            completion(.failure(URLError(.userAuthenticationRequired))) // Token missing
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Add the token to Authorization header
        
        do {
            let jsonData = try JSONEncoder().encode(request)
            urlRequest.httpBody = jsonData
            print("Request JSON: \(String(data: jsonData, encoding: .utf8) ?? "Invalid JSON")")
        } catch {
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Request Error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response received")
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 201 { // Assuming 201 Created is the success status code
                // Handle successful response
                if let data = data {
                    do {
                        let responseDict = try JSONDecoder().decode([String: String].self, from: data)
                        if let message = responseDict["message"] {
                            completion(.success(message))
                        } else {
                            completion(.failure(URLError(.badServerResponse)))
                        }
                    } catch {
                        print("Response Decoding Error: \(error.localizedDescription)")
                        completion(.failure(error))
                    }
                } else {
                    completion(.failure(URLError(.badServerResponse)))
                }
            } else {
                // Handle unsuccessful response
                if let data = data {
                    let responseString = String(data: data, encoding: .utf8) ?? "No data"
                    print("Response Data: \(responseString)")
                    completion(.failure(URLError(.badServerResponse)))
                } else {
                    completion(.failure(URLError(.badServerResponse)))
                }
            }
        }
        
        task.resume()
    }
    
    func fetchMessages(for vehicleNumber: String, completion: @escaping (Result<[TruckMessage], Error>) -> Void) {
            let urlString = "https://napixbackend-2.onrender.com/api/vehicles/messages/\(vehicleNumber)" // Adjust URL accordingly
            guard let url = URL(string: urlString) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                // Print the raw response for debugging
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Raw Response: \(responseString)")
                }
                
                do {
                    // Decode the response based on the TruckMessagesResponse model
                    let decodedResponse = try JSONDecoder().decode(TruckMessagesResponse.self, from: data)
                    completion(.success(decodedResponse))
                } catch {
                    completion(.failure(error))
                }
            }.resume()
        }



    
}
