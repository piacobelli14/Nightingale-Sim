//
//  ContentView.swift
//  NightingaleSim
//
//  Created by Peter Iacobelli on 5/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var currentView: AppView = .StaticSim
    @State private var authenticatedUsername: String = ""
    @State private var authenticatedOrgID: String = ""
    @State private var targetDevice: String = ""
    @State private var isMotion: Bool = true
    @State private var isHealth: Bool = true
    @State private var isGeolocation: Bool = true
    @State private var dataFrequency: Int = 1
    @State private var accUpperBound: Double = 0.1
    @State private var accLowerBound: Double = -0.1
    @State private var gyroUpperBound: Double = 20.0
    @State private var gyroLowerBound: Double = -20.0
    @State private var magUpperBound: Double = 10.0
    @State private var magLowerBound: Double = -10.0
    @State private var hrUpperBound: Double = 6
    @State private var hrLowerBound: Double = -6
    @State private var spo2UpperBound: Double = 3
    @State private var spo2LowerBound: Double = -3
    @State private var isLoggedOut: Bool = false

    var body: some View {
        Group {
            switch currentView {
            case .LoginAuth:
                LoginAuth(currentView: $currentView, authenticatedUsername: $authenticatedUsername, authenticatedOrgID: $authenticatedOrgID)
                    .onAppear {
                        deleteTokenFromKeychain()
                        authenticatedUsername = ""
                        authenticatedOrgID = ""
                    }
            case .ResetAuth:
                ResetAuth(currentView: $currentView)
                    .onAppear { checkToken() }
            case .StaticSim:
                StaticSim(currentView: $currentView, authenticatedUsername: $authenticatedUsername, authenticatedOrgID: $authenticatedOrgID, targetDevice: $targetDevice, isMotion: $isMotion, isHealth: $isHealth, isGeolocation: $isGeolocation, dataFrequency: $dataFrequency, accUpperBound: $accUpperBound, accLowerBound: $accLowerBound, gyroUpperBound: $gyroUpperBound, gyroLowerBound: $gyroLowerBound, magUpperBound: $magUpperBound, magLowerBound: $magLowerBound, hrUpperBound: $hrUpperBound, hrLowerBound: $hrLowerBound, spo2UpperBound: $spo2UpperBound, spo2LowerBound: $spo2LowerBound)
                    .onAppear { checkToken() }
            case .SettingsSim:
                SettingsSim(currentView: $currentView, authenticatedUsername: $authenticatedUsername, authenticatedOrgID: $authenticatedOrgID, targetDevice: $targetDevice, isMotion: $isMotion, isHealth: $isHealth, isGeolocation: $isGeolocation, dataFrequency: $dataFrequency, accUpperBound: $accUpperBound, accLowerBound: $accLowerBound, gyroUpperBound: $gyroUpperBound, gyroLowerBound: $gyroLowerBound, magUpperBound: $magUpperBound, magLowerBound: $magLowerBound, hrUpperBound: $hrUpperBound, hrLowerBound: $hrLowerBound, spo2UpperBound: $spo2UpperBound, spo2LowerBound: $spo2LowerBound)
                    .onAppear { checkToken() }
            }
        }
        .onAppear {
            initializeView()
        }
        .onChange(of: currentView) { newView in
            checkToken()
        }
    }

    func checkToken() {
        if let token = loadTokenFromKeychain() {
            if isTokenExpired(token: token) {
                deleteTokenFromKeychain()
                isLoggedOut = true
                currentView = .LoginAuth
            } else {
                decodeToken(token: token)
            }
        } else {
            isLoggedOut = true
            currentView = .LoginAuth
        }
    }
    
    func initializeView() {
        if let token = loadTokenFromKeychain(), !isTokenExpired(token: token) {
            decodeToken(token: token)
            currentView = .StaticSim
        } else {
            currentView = .LoginAuth
        }
    }

    func decodeToken(token: String) {
        let parts = token.split(separator: ".")
        guard parts.count == 3 else {
            return
        }

        let payload = parts[1]
        var base64String = String(payload)
        
        while base64String.count % 4 != 0 {
            base64String.append("=")
        }

        guard let decodedData = Data(base64Encoded: base64String) else {
            return
        }

        guard let json = try? JSONSerialization.jsonObject(with: decodedData, options: []),
              let dict = json as? [String: Any] else {
            return
        }

        if let username = dict["username"] as? String {
            authenticatedUsername = username
        }

        if let orgID = dict["orgid"] as? String {
            authenticatedOrgID = orgID
        }

        if let exp = dict["exp"] as? TimeInterval {
            let expirationDate = Date(timeIntervalSince1970: exp)
            let isExpired = Date() > expirationDate
        }
    }
}
