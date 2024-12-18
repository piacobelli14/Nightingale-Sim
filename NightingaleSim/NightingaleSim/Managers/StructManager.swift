//
//  StructManager.swift
//  NightingaleSim
//
//  Created by Peter Iacobelli on 6/11/24.
//

import Foundation
import MapKit

struct LoginResponse: Codable {
    let userid: String
    let orgid: String
    let token: String
}

struct ConfigArray {
    let minimumValue: CGFloat
    let maximumValue: CGFloat
    let totalValue: CGFloat
    let step: CGFloat
    let knobRadius: CGFloat
    let radius: CGFloat
}

struct DeviceInfo: Decodable {
    let assignedTo: String
    let devBattery: Int
    let devID: String
    let devType: String
    let lastAssigned: Date
    let orgID: String
    let devCPUUsage: Double?
    let devNetworkUsage: Double?

    
}

struct DeviceResponse: Decodable {
    let data: [DeviceInfo]
    let message: String
}

struct LocationData {
    var latitude: Double
    var longitude: Double
    var altitude: Double
}

struct LocationPin: Identifiable {
    let id = UUID()
    var location: CLLocationCoordinate2D
}

struct NominatimResult: Codable {
    let display_name: String
    let lat: String
    let lon: String
}

struct OpenMeteoElevationResponse: Decodable {
    let elevation: [Double]
}
