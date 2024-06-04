//
//  SettingsSim.swift
//  NightingaleSim
//
//  Created by Peter Iacobelli on 5/12/24.
//

import SwiftUI

struct DeviceInfo: Codable {
    let devType: String
    let devID: String
    let assignedTo: String
    let lastAssigned: String
    let battery: String
}

struct SettingsSim: View {
    @Binding var currentView: AppView
    @Binding var authenticatedUsername: String
    @Binding var authenticatedOrgID: String
    @Binding var targetDevice: String
    @Binding var isMotion: Bool
    @Binding var isHealth: Bool
    @Binding var isGeolocation: Bool
    @Binding var motionFrequency: Int
    @Binding var healthFrequency: Int
    @Binding var geolocationFrequency: Int
    @Binding var accUpperBound: Double
    @Binding var accLowerBound: Double
    @Binding var gyroUpperBound: Double
    @Binding var gyroLowerBound: Double
    @Binding var magUpperBound: Double
    @Binding var magLowerBound: Double
    @Binding var hrUpperBound: Double
    @Binding var hrLowerBound: Double
    @Binding var respUpperBound: Double
    @Binding var respLowerBound: Double
    
    @State private var deviceInfo: [DeviceInfo] = []
    @State private var availableDevIDs: [String] = []
    
    @State private var errorMessage: String? = nil

    
    let gradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: 0x381A68), Color(hex: 0x5B4D72)]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
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
                    
                    VStack {
                        HStack {
                            VStack {
                                HStack {
                                    Text("Configure Sensors")
                                        .font(.system(size: geometry.size.height * 0.016, weight: .bold))
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
                                        .font(.system(size: geometry.size.height * 0.016, weight: .bold))
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
                                        
                                        Text("\(authenticatedOrgID)")
                                        
                                            .font(.system(size: geometry.size.height * 0.016, weight: .semibold))
                                            .foregroundColor(Color.white)
                                            .opacity(0.6)
                                            .padding(.leading, geometry.size.width * 0.02)
                                        
                                        Spacer()
                                    }
                                    .padding(.top, geometry.size.height * 0.01)
                                    
                                    VStack(alignment: .leading) {
                                        Text("Target Device:")
                                            .font(.system(size: geometry.size.height * 0.016, weight: .bold))
                                            .foregroundColor(Color.white)
                                            .opacity(0.8)
                                            .padding(.leading, geometry.size.width * 0.01)
                                        
                                        Menu {
                                            ForEach(availableDevIDs, id: \.self) { id in
                                                Button(id) {
                                                    targetDevice = id
                                                }
                                            }
                                        } label: {
                                            Text(targetDevice == "" ? "Select A Device" : targetDevice)
                                                .autocapitalization(.none)
                                                .disableAutocorrection(true)
                                                .foregroundColor(.black)
                                                .font(.system(size: geometry.size.height * 0.02, weight: .light, design: .default))
                                                .multilineTextAlignment(.leading)
                                                .padding(.vertical, geometry.size.height * 0.016)
                                                .padding(.horizontal, geometry.size.width * 0.02)
                                                .background(Color(hex: 0xF5F5F5).opacity(0.9))
                                                .border(Color(hex: 0x504F51), width: geometry.size.width * 0.002)
                                                .cornerRadius(geometry.size.height * 0.01)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: geometry.size.height * 0.01)
                                                        .stroke(Color(hex: 0x504F51), lineWidth: geometry.size.width * 0.002)
                                                )
                                                .shadow(color: .gray.opacity(0.3), radius: 1, x: 0, y: 0)
                                                
                                        }
                                        .accentColor(.black)
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
                        
                        HStack {
                            Spacer()
                            VStack {
                                Text("Health Sensor")
                                    .font(.system(size: geometry.size.height * 0.016, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.25)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(geometry.size.height * 0.005)
                            .shadow(radius: 5)
                            .padding(.top, geometry.size.height * 0.002)
                            
                            VStack {
                                Text("Motion Sensor")
                                    .font(.system(size: geometry.size.height * 0.016, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.25)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(geometry.size.height * 0.005)
                            .shadow(radius: 5)
                            .padding(.top, geometry.size.height * 0.002)
                            
                            VStack {
                                Text("Geolocation Sensor")
                                    .font(.system(size: geometry.size.height * 0.016, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(width: geometry.size.width * 0.3, height: geometry.size.height * 0.25)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(geometry.size.height * 0.005)
                            .shadow(radius: 5)
                            .padding(.top, geometry.size.height * 0.002)
                            
                           Spacer()
                        }
                        .frame(width: geometry.size.width * 0.92)
                    }
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
                                self.authenticatedUsername = ""
                                self.currentView = .LoginAuth
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
                    .padding(.top, geometry.size.height * 0.014)
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
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .onAppear {
                self.getAvailableDevices()
            }
        }
    }
    private func getAvailableDevices() {
        let url = URL(string: "http://172.20.10.2:5000/get-devices")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    print(self.errorMessage)
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received from the server"
                    print(self.errorMessage)
                }
                return
            }

            guard let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response from the server"
                    print(self.errorMessage)
                }
                return
            }

            if response.statusCode == 200 {
                do {
                    let decodedData = try JSONDecoder().decode([DeviceInfo].self, from: data)
                    DispatchQueue.main.async {
                        self.deviceInfo = decodedData
                        self.availableDevIDs = decodedData.map { $0.devID }
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "JSON decoding error: \(error.localizedDescription)"
                        print(self.errorMessage)
                    }
                }

            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Server error with status code: \(response.statusCode)"
                    print(self.errorMessage)
                }
            }
        }
        .resume()
    }

}
