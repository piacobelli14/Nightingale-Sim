//
//  ContentView.swift
//  NightingaleSim
//
//  Created by Peter Iacobelli on 5/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var currentView: AppView = .LoginAuth
    @State private var authenticatedUsername: String = ""
    @State private var authenticatedOrgID: String = ""
    @State private var targetDevice: String = ""
    @State private var isMotion: Bool = true
    @State private var isHealth: Bool = true
    @State private var isGeolocation: Bool = true
    @State private var motionFrequency: Int = 10
    @State private var healthFrequency: Int = 30
    @State private var geolocationFrequency: Int = 30
    @State private var accUpperBound: Double = 0.1
    @State private var accLowerBound: Double = -0.1
    @State private var gyroUpperBound: Double = 20.0
    @State private var gyroLowerBound: Double = -20.0
    @State private var magUpperBound: Double = 10.0
    @State private var magLowerBound: Double = -10.0
    @State private var hrUpperBound: Double = 6
    @State private var hrLowerBound: Double = -6
    @State private var respUpperBound: Double = 3
    @State private var respLowerBound: Double = -3
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
                        targetDevice = ""
                    }
            case .ResetAuth:
                ResetAuth(currentView: $currentView)
            case .StaticSim:
                StaticSim(currentView: $currentView, authenticatedUsername: $authenticatedUsername, authenticatedOrgID: $authenticatedOrgID, targetDevice: $targetDevice, isMotion: $isMotion, isHealth: $isHealth, isGeolocation: $isGeolocation, motionFrequency: $motionFrequency, healthFrequency: $healthFrequency, geolocationFrequency: $geolocationFrequency, accUpperBound: $accUpperBound, accLowerBound: $accLowerBound, gyroUpperBound: $gyroUpperBound, gyroLowerBound: $gyroLowerBound, magUpperBound: $magUpperBound, magLowerBound: $magLowerBound, hrUpperBound: $hrUpperBound, hrLowerBound: $hrLowerBound, respUpperBound: $respUpperBound, respLowerBound: $respLowerBound)
            case .SettingsSim:
                SettingsSim(currentView: $currentView, authenticatedUsername: $authenticatedUsername, authenticatedOrgID: $authenticatedOrgID, targetDevice: $targetDevice, isMotion: $isMotion, isHealth: $isHealth, isGeolocation: $isGeolocation, motionFrequency: $motionFrequency, healthFrequency: $healthFrequency, geolocationFrequency: $geolocationFrequency, accUpperBound: $accUpperBound, accLowerBound: $accLowerBound, gyroUpperBound: $gyroUpperBound, gyroLowerBound: $gyroLowerBound, magUpperBound: $magUpperBound, magLowerBound: $magLowerBound, hrUpperBound: $hrUpperBound, hrLowerBound: $hrLowerBound, respUpperBound: $respUpperBound, respLowerBound: $respLowerBound)
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
            }
        } else {
            isLoggedOut = true
            currentView = .LoginAuth
        }
    }
    
    func initializeView() {
        if let token = loadTokenFromKeychain(), !isTokenExpired(token: token) {
            currentView = .StaticSim
        } else {
            currentView = .LoginAuth
        }
    }
}




