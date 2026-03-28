//
//  DriverModel.swift
//  WebstarF1App
//
//  Created by Bence on 2026.03.23.
//

struct Driver: Codable, Identifiable, Hashable {
    let id: String
    let racingNumber: String?
    let code: String?
    let givenName: String
    let familyName: String
    let dateOfBirth: String?
    let nationality: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
            case id = "driverId"
            case racingNumber = "permanentNumber"
            case code
            case givenName
            case familyName
            case dateOfBirth
            case nationality
            case url
        }
}

struct DriverTable: Codable {
    let drivers : [Driver]
    
    enum CodingKeys: String, CodingKey {
            case drivers = "Drivers"
        }
}

struct DriverMRData: Codable {
    let driverTable: DriverTable
    
    enum CodingKeys: String, CodingKey {
            case driverTable = "DriverTable"
        }
}

struct DriverResponse: Codable {
    let mrData: DriverMRData
    
    enum CodingKeys: String, CodingKey {
        case mrData = "MRData"
    }
    
    var drivers: [Driver] { mrData.driverTable.drivers }
}
