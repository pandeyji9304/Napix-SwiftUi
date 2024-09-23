//
//  LogsticsHead.swift
//  Napix
//
//  Created by Ritik Pandey on 14/09/24.
//

import Foundation

struct LogisticsUser: Codable {
    let name: String
    let email: String
    let phoneNumber: String
    let password: String
    let companyName: String
}

struct VehicleAlert: Identifiable, Codable {
    let id: UUID = UUID()
    let vehicleNumber: String
    
}




struct UserProfile: Codable {
    let id: String
    let name: String
    let email: String
    let phoneNumber: String
    let companyName: String
}

struct Driver: Codable, Identifiable {
    var id: String
    let name: String
    let mobileNumber: String
    let email: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "_id" // Map the '_id' field from the JSON to 'id'
        case name
        case mobileNumber
        case email
    }
}






struct LoginResponse: Codable {
    let token: String
    let role: String
}

struct RouteResponse: Codable {
    let routes: [Route]
}

struct Route: Codable, Identifiable {
    let id = UUID() // or if your data has a unique ID, use that instead
    let departureDetails: DepartureDetails
    let _id: String
    let vehicleNumber: String
    let driverName: String
    let fromLocation: String
    let toLocation: String
    let status: String
    let assignedTruck: AssignedTruck

    enum CodingKeys: String, CodingKey {
        case departureDetails
        case _id
        case vehicleNumber
        case driverName
        case fromLocation
        case toLocation
        case status
        case assignedTruck
    }
}

struct DepartureDetails: Codable {
    let departureTime: String
}

struct AssignedTruck: Codable {
    let _id: String
    let vehicleNumber: String
}



struct RouteCreationRequest: Codable {
    let vehicleNumber: String
    let driverName: String
    let fromLocation: String
    let toLocation: String
    let departureDetails: DepartureDetails
}


struct Message: Codable,Identifiable {
    let message: String
    let timestamp: String
    let id: String
    
    enum CodingKeys: String, CodingKey {
        case message
        case timestamp
        case id = "_id"
    }
}

struct TruckMessage: Identifiable, Codable {
    let id: String
    let truckNumber: String
    let messages: [Message]

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case truckNumber
        case messages
    }
}

// Define a response structure if needed
typealias TruckMessagesResponse = [TruckMessage]
