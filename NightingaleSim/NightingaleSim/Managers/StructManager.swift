//
//  StructManager.swift
//  NightingaleSim
//
//  Created by Peter Iacobelli on 6/11/24.
//

import Foundation

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

struct DeviceInfo: Codable {
    let devID: String
    let devType: String
    let orgID: String
    let assignedTo: String?
    let lastAssigned: String
    let devBattery: String
}

struct DeviceInfoResponse: Codable {
    let data: [DeviceInfo]
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
