//
//  ContentView.swift
//  NightingaleSim
//
//  Created by Peter Iacobelli on 5/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var currentView: AppView = .SettingsSim
    @State private var authenticatedUsername: String = "piacobelli"
    @State private var authenticatedOrgID: String = "10000"
    @State private var isMotion: Bool = true
    @State private var isHealth: Bool = true
    @State private var isGeolocation: Bool = true
    @State private var motionFrequency: Int = 10
    @State private var healthFrequency: Int = 1
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
    
    
    
    var body: some View {
        switch currentView {
        case .StaticSim:
            StaticSim(currentView: $currentView, authenticatedUsername: $authenticatedUsername, authenticatedOrgID: $authenticatedOrgID, isMotion: $isMotion, isHealth: $isHealth, isGeolocation: $isGeolocation, motionFrequency: $motionFrequency, healthFrequency: $healthFrequency, geolocationFrequency: $geolocationFrequency, accUpperBound: $accUpperBound, accLowerBound: $accLowerBound, gyroUpperBound: $gyroUpperBound, gyroLowerBound: $gyroLowerBound, magUpperBound: $magUpperBound, magLowerBound: $magLowerBound, hrUpperBound: $hrUpperBound, hrLowerBound: $hrLowerBound, respUpperBound: $respUpperBound, respLowerBound: $respLowerBound)
        case .SettingsSim:
            SettingsSim(currentView: $currentView, authenticatedUsername: $authenticatedUsername, authenticatedOrgID: $authenticatedOrgID, isMotion: $isMotion, isHealth: $isHealth, isGeolocation: $isGeolocation, motionFrequency: $motionFrequency, healthFrequency: $healthFrequency, geolocationFrequency: $geolocationFrequency, accUpperBound: $accUpperBound, accLowerBound: $accLowerBound, gyroUpperBound: $gyroUpperBound, gyroLowerBound: $gyroLowerBound, magUpperBound: $magUpperBound, magLowerBound: $magLowerBound, hrUpperBound: $hrUpperBound, hrLowerBound: $hrLowerBound, respUpperBound: $respUpperBound, respLowerBound: $respLowerBound)
        case .LoginAuth:
            LoginAuth(currentView: $currentView, authenticatedUsername: $authenticatedUsername, authenticatedOrgID: $authenticatedOrgID)
        case .ResetAuth:
            ResetAuth(currentView: $currentView)
        }
    }
}

