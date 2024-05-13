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
    @Binding var isMotion: Bool
    @Binding var isHealth: Bool
    @Binding var isGeolocation: Bool
    
    let gradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: 0x381A68), Color(hex: 0x5B4D72)]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    @State private var orgID: String = ""
    
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
                                    .padding(.leading, geometry.size.width * 0.01)
                                
                                Spacer()
                            }
                            
                            HStack {
                                Text("Health Sensor")
                                    .font(.system(size: geometry.size.height * 0.018, weight: .semibold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.6)
                                    .padding(.horizontal, geometry.size.width * 0.01)
                                
                                Spacer()
                                
                                HStack {
                                    Toggle("", isOn: $isHealth)
                                        .tint(Color(hex: 0x2A0862))
                                        .labelsHidden()
                                    
                                    Text("\(isHealth ? "On" : "Off")")
                                        .font(.system(size: geometry.size.height * 0.018, weight: .heavy))
                                        .foregroundColor(isHealth ? Color.green : Color.red)
                                        .opacity(0.8)
                                        .padding(.leading, geometry.size.width * 0.01)
                                }
                            }
                            .padding(.top, geometry.size.height * 0.01)
                                
                            HStack {
                                Text("Motion Sensor")
                                    .font(.system(size: geometry.size.height * 0.018, weight: .semibold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.6)
                                    .padding(.horizontal, geometry.size.width * 0.01)
                                
                                Spacer()
                                
                                HStack {
                                    Toggle("", isOn: $isMotion)
                                        .tint(Color(hex: 0x2A0862))
                                        .labelsHidden()
                                    
                                    Text("\(isMotion ? "On" : "Off")")
                                        .font(.system(size: geometry.size.height * 0.018, weight: .heavy))
                                        .foregroundColor(isMotion ? Color.green : Color.red)
                                        .opacity(0.8)
                                        .padding(.leading, geometry.size.width * 0.01)
                                }
                            }
                            .padding(.top, geometry.size.height * 0.01)
                            
                            HStack {
                                Text("Geolocation Sensor")
                                    .font(.system(size: geometry.size.height * 0.018, weight: .semibold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.6)
                                    .padding(.horizontal, geometry.size.width * 0.01)
                                
                                Spacer()
                                
                                HStack {
                                    Toggle("", isOn: $isGeolocation)
                                        .tint(Color(hex: 0x2A0862))
                                        .labelsHidden()
                                    
                                    Text("\(isGeolocation ? "On" : "Off")")
                                        .font(.system(size: geometry.size.height * 0.018, weight: .heavy))
                                        .foregroundColor(isGeolocation ? Color.green : Color.red)
                                        .opacity(0.8)
                                        .padding(.leading, geometry.size.width * 0.01)
                                }
                            }
                            .padding(.top, geometry.size.height * 0.01)
                            Spacer()
                        }
                        .frame(height: geometry.size.height * 0.25)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(geometry.size.height * 0.005)
                        .shadow(radius: 5)
                        
                        VStack {
                            HStack {
                                Text("Current User")
                                    .font(.system(size: geometry.size.height * 0.02, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .padding(.vertical, geometry.size.height * 0.01)
                                    .padding(.leading, geometry.size.width * 0.01)
                                
                                Spacer()
                            }
                            
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Username:")
                                        .font(.system(size: geometry.size.height * 0.016, weight: .bold))
                                        .foregroundColor(Color.white)
                                        .opacity(0.8)
                                        .padding(.leading, geometry.size.width * 0.01)
                                    
                                    Text("@"+"\(authenticatedUsername)")
                                        .font(.system(size: geometry.size.height * 0.016, weight: .semibold))
                                        .foregroundColor(Color.white)
                                        .opacity(0.6)
                                        .padding(.leading, geometry.size.width * 0.02)
                                    
                                    Spacer()
                                }
                                .padding(.top, geometry.size.height * 0.01)
                                
                                HStack {
                                    Text("Organization ID:")
                                        .font(.system(size: geometry.size.height * 0.016, weight: .bold))
                                        .foregroundColor(Color.white)
                                        .opacity(0.8)
                                        .padding(.leading, geometry.size.width * 0.01)
                                    
                                    Text("\(orgID)")

                                        .font(.system(size: geometry.size.height * 0.016, weight: .semibold))
                                        .foregroundColor(Color.white)
                                        .opacity(0.6)
                                        .padding(.leading, geometry.size.width * 0.02)
                                    
                                    Spacer()
                                }
                                .padding(.top, geometry.size.height * 0.01)
                                
                                HStack {
                                    Text("Device ID:")
                                        .font(.system(size: geometry.size.height * 0.016, weight: .bold))
                                        .foregroundColor(Color.white)
                                        .opacity(0.8)
                                        .padding(.leading, geometry.size.width * 0.01)
                                    
                                    Text("awse-1SIM")

                                        .font(.system(size: geometry.size.height * 0.016, weight: .semibold))
                                        .foregroundColor(Color.white)
                                        .opacity(0.6)
                                        .padding(.leading, geometry.size.width * 0.02)
                                    
                                    Spacer()
                                }
                                .padding(.top, geometry.size.height * 0.01)
                            }
                            
                            Spacer()
                        }
                        .frame(height: geometry.size.height * 0.25)
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
            .onAppear {
                self.getUserInfo()
            }
        }
    }
    private func getUserInfo() {
        let requestBody: [String: Any] = [
            "username": authenticatedUsername
        ]

        guard let url = URL(string: "http://172.20.10.2:5000/get-user-information") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            print("Error creating JSON body: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error making request: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type.")
                return
            }

            if httpResponse.statusCode == 200 {
                guard let data = data else {
                    print("No data received")
                    return
                }

                do {
                    if let jsonResult = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        DispatchQueue.main.async {
                            self.orgID = jsonResult["orgID"] as? String ?? ""
                        }
                    } else {
                        print("Error: JSON structure did not match expected [String: Any]")
                    }
                } catch {
                    print("Error parsing JSON: \(error.localizedDescription)")
                }
            } else {
                print("Server returned status code: \(httpResponse.statusCode)")
            }
        }.resume()
    }

}
