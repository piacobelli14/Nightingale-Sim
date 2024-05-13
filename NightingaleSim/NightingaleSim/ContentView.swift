//
//  ContentView.swift
//  NightingaleSim
//
//  Created by Peter Iacobelli on 5/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var currentView: AppView = .StaticSim
    @State private var authenticatedUsername: String = "piacobelli"
    @State private var isMotion: Bool = true
    @State private var isHealth: Bool = true
    @State private var isGeolocation: Bool = true
    
    
    var body: some View {
        switch currentView {
        case .StaticSim:
            StaticSim(currentView: $currentView, authenticatedUsername: $authenticatedUsername, isMotion: $isMotion, isHealth: $isHealth, isGeolocation: $isGeolocation)
        case .SettingsSim:
            SettingsSim(currentView: $currentView, authenticatedUsername: $authenticatedUsername, isMotion: $isMotion, isHealth: $isHealth, isGeolocation: $isGeolocation)
        }
    }
}

