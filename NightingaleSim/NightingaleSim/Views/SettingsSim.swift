//
//  SettingsSim.swift
//  NightingaleSim
//
//  Created by Peter Iacobelli on 5/12/24.
//

import SwiftUI

struct SettingsSim: View {
    @Binding var currentView: AppView
    @Binding var authenticatedUsername: String

    let gradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: 0x381A68), Color(hex: 0x5B4D72)]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    @State private var isMotion: Bool = true
    @State private var isHealth: Bool = true
    @State private var isGeolocation: Bool = true
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Image("nslogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: geometry.size.height * 0.07)
                        .shadow(color: .gray.opacity(0.5), radius: 3, x: 0, y: 0)
                        .padding(.leading, geometry.size.width * 0.01)
                    
                    Text("Nightinagle Sim")
                        .font(.system(size: geometry.size.height * 0.03, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .gray.opacity(0.3), radius: 0, x: 0, y: 2)
                    
                    Spacer()
                }
                .frame(width: geometry.size.width * 1.0)
                .padding(.top, geometry.size.height * 0.05)
                .edgesIgnoringSafeArea(.all)
                .background(
                    VStack {
                        Spacer()
                        Rectangle()
                            .frame(height: geometry.size.height * 0.001)
                            .foregroundColor(.gray)
                    }
                )
                
                ScrollView {
                    
                    HStack {
                        VStack {
                            HStack {
                                Text("Configure Sensors")
                                    .font(.system(size: geometry.size.height * 0.02, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .padding(.vertical, geometry.size.height * 0.01)
                                
                                Spacer()
                            }
                                
                            
                            HStack {
                                Text("Motion Sensor")
                                    .font(.system(size: geometry.size.height * 0.018, weight: .regular))
                                    .foregroundColor(Color.white)
                                    .padding(.trailing, geometry.size.width * 0.02)
                                
                                HStack {
                                    Toggle("", isOn: $isMotion)
                                        .tint(Color(hex: 0x2A0862))
                                        .labelsHidden()
                                    
                                    Spacer()
                                    
                                    Text("\(isMotion ? "On" : "Off")")
                                        .font(.system(size: geometry.size.height * 0.018, weight: .semibold))
                                        .foregroundColor(Color.white)
                                        .opacity(0.8)
                                        .padding(.leading, geometry.size.width * 0.01)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(geometry.size.height * 0.005)
                        .shadow(radius: 5)
                        
                        VStack {
                            HStack {
                                Text("Configure Sensors")
                                    .font(.system(size: geometry.size.height * 0.02, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .padding(.vertical, geometry.size.height * 0.01)
                                
                                Spacer()
                            }
                                
                            
                            HStack {
                                Text("Motion Sensor")
                                    .font(.system(size: geometry.size.height * 0.018, weight: .regular))
                                    .foregroundColor(Color.white)
                                    .padding(.trailing, geometry.size.width * 0.02)
                                
                                HStack {
                                    Toggle("", isOn: $isMotion)
                                        .tint(Color(hex: 0x2A0862))
                                        .labelsHidden()
                                    
                                    Spacer()
                                    
                                    Text("\(isMotion ? "On" : "Off")")
                                        .font(.system(size: geometry.size.height * 0.018, weight: .semibold))
                                        .foregroundColor(Color.white)
                                        .opacity(0.8)
                                        .padding(.leading, geometry.size.width * 0.01)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(geometry.size.height * 0.005)
                        .shadow(radius: 5)
                    }
                    .frame(width: geometry.size.width * 0.92)
                    .padding(.top, geometry.size.height * 0.02)
                    
                    
                
                }
                .frame(height: geometry.size.height * 0.82)
                .frame(width: geometry.size.width * 1.0)
                
                Spacer()
                
                HStack(alignment: .center) {
                    
                    Spacer()
                    
                    HStack {
                        
                        VStack {
                            Button(action: {
                                self.currentView = .StaticSim
                            }) {
                                Image(systemName: "hourglass")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: geometry.size.height * 0.022)
                                    .foregroundColor(Color.white)
                                    .shadow(color: .gray.opacity(0.5), radius: 3, x: 0, y: 0)
                                    .padding(.leading, geometry.size.width * 0.01)
                            }
                            
                            Text("Simulator")
                                .font(.system(size: geometry.size.height * 0.012, weight: .semibold))
                                .foregroundColor(Color.white)
                                .opacity(0.6)
                        }
                        .padding(.trailing, geometry.size.width * 0.01)
                        
                        VStack {
                            Button(action: {
                                
                            }) {
                                Image(systemName: "lock")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: geometry.size.height * 0.022)
                                    .foregroundColor(Color.white)
                                    .shadow(color: .gray.opacity(0.5), radius: 3, x: 0, y: 0)
                                    .padding(.leading, geometry.size.width * 0.01)
                            }
                            
                            Text("Logout")
                                .font(.system(size: geometry.size.height * 0.012, weight: .semibold))
                                .foregroundColor(Color.white)
                                .opacity(0.6)
                        }
                        .padding(.trailing, geometry.size.width * 0.03)
                    }
                    .padding(.top, geometry.size.height * 0.01)
                    .padding(.bottom, geometry.size.height * 0.01)
                    
                    
                }
                .frame(width: geometry.size.width * 1.0)
                .edgesIgnoringSafeArea(.all)
                .background(Color(hex: 0x504F51))
                .background(
                    VStack {
                        Rectangle()
                            .frame(height: geometry.size.height * 0.001)
                            .foregroundColor(.gray)
                        Spacer()
                    }
                )
                
            }
            .frame(width: geometry.size.width * 1.0, height: geometry.size.height * 1.0)
            .background(gradient)
        }
    }
}
