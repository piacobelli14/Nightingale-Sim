//
//  StaticSim.swift
//  NightingaleSim
//
//  Created by Peter Iacobelli on 5/10/24.
//

import SwiftUI
import MapKit
import Combine

struct MotionSensorGauge: View {
    @Binding var motionValue: CGFloat
    @State var angleValue: CGFloat = 0.0
    var configArray: ConfigArray
    var motionVector: String
    var motionUnit: String

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            let strokeStyle = StrokeStyle(lineWidth: size * 0.02, lineCap: .butt, dash: [size * 0.2, size * 0.15])
            let mainStrokeWidth = size * 0.04
            ZStack {
                Circle()
                    .frame(width: size, height: size)
                    .foregroundColor(.clear)
                Circle()
                    .stroke(Color.gray, style: strokeStyle)
                    .frame(width: size, height: size)
                Circle()
                    .trim(from: 0.0, to: normalizedMotionValue())
                    .stroke(Color.blue, lineWidth: mainStrokeWidth)
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
                Circle()
                    .fill(Color.blue)
                    .frame(width: size * 0.2, height: size * 0.2)
                    .offset(y: -(size / 1.95 - mainStrokeWidth / 1.95))
                    .rotationEffect(Angle.degrees(Double(angleValue)))
                    .gesture(DragGesture(minimumDistance: 0).onChanged({ value in
                        self.change(location: value.location, in: size)
                    }))
                Text("\(motionVector): \(motionValue, specifier: "%.1f")\(motionUnit)")
                    .font(.system(size: size * 0.12, weight: .bold))
                    .foregroundColor(.white)
            }
            .background(Color.clear)
        }
    }

    private func normalizedMotionValue() -> CGFloat {
        let range = configArray.maximumValue - configArray.minimumValue
        return (motionValue - configArray.minimumValue) / range
    }

    private func change(location: CGPoint, in size: CGFloat) {
        let vector = CGVector(dx: location.x - size / 2, dy: location.y - size / 2)
        let angle = atan2(vector.dy, vector.dx) + .pi / 2.0
        let fixedAngle = angle < 0.0 ? angle + 2.0 * .pi : angle
        let totalRange = configArray.maximumValue - configArray.minimumValue
        var value = (fixedAngle / (2.0 * .pi)) * totalRange + configArray.minimumValue
        
        value = round(value / configArray.step) * configArray.step
        
        if value >= configArray.minimumValue && value <= configArray.maximumValue {
            motionValue = value
            angleValue = fixedAngle * 180 / .pi
        }
    }
}

struct ConfigArray {
    let minimumValue: CGFloat
    let maximumValue: CGFloat
    let totalValue: CGFloat
    let step: CGFloat
    let knobRadius: CGFloat
    let radius: CGFloat
}

struct StaticSim: View {
    @Binding var currentView: AppView
    @Binding var authenticatedUsername: String
    @Binding var authenticatedOrgID: String
    @Binding var isMotion: Bool
    @Binding var isHealth: Bool
    @Binding var isGeolocation: Bool
    @Binding var motionFrequency: Int
    @Binding var healthFrequency: Int
    @Binding var geolocationFrequency: Int
    @Binding var accUpperBound: CGFloat
    @Binding var accLowerBound: CGFloat
    @Binding var gyroUpperBound: CGFloat
    @Binding var gyroLowerBound: CGFloat
    @Binding var magUpperBound: CGFloat
    @Binding var magLowerBound: CGFloat
    @Binding var hrUpperBound: Int
    @Binding var hrLowerBound: Int
    @Binding var respUpperBound: Int
    @Binding var respLowerBound: Int
    
    @State private var motionTimer: AnyCancellable?
    @State private var healthTimer: AnyCancellable?
    @State private var motionDataCollection = [[String: Any]]()

    let gradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: 0x381A68), Color(hex: 0x5B4D72)]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    @State private var isRandom: Bool = false
    @State private var showInfoPopover = false
    
    @State private var heartRate: Double = 70
    @State private var respirationRate: Double = 12
    @State private var deviceBattery: Double = 85
    @State private var isConnected: Bool = true
    @State private var accX: CGFloat = 2.0
    @State private var accY: CGFloat = 2.0
    @State private var accZ: CGFloat = 2.0
    @State private var gyroX: CGFloat = 500.0
    @State private var gyroY: CGFloat = 500.0
    @State private var gyroZ: CGFloat = 500.0
    @State private var magX: CGFloat = 100.0
    @State private var magY: CGFloat = 100.0
    @State private var magZ: CGFloat = 100.0
    
    let configAccX = ConfigArray(minimumValue: -2.0, maximumValue: 2.0, totalValue: 20.0, step: 0.1, knobRadius: 15.0, radius: 125.0)
    let configAccY = ConfigArray(minimumValue: -2.0, maximumValue: 2.0, totalValue: 20.0, step: 0.1, knobRadius: 15.0, radius: 125.0)
    let configAccZ = ConfigArray(minimumValue: -2.0, maximumValue: 2.0, totalValue: 20.0, step: 0.1, knobRadius: 15.0, radius: 125.0)
    var configGyroX = ConfigArray(minimumValue: -500.0, maximumValue: 500.0, totalValue: 1000.0, step: 1.0, knobRadius: 15.0, radius: 125.0)
    var configGyroY = ConfigArray(minimumValue: -500.0, maximumValue: 500.0, totalValue: 1000.0, step: 1.0, knobRadius: 15.0, radius: 125.0)
    var configGyroZ = ConfigArray(minimumValue: -500.0, maximumValue: 500.0, totalValue: 1000.0, step: 1.0, knobRadius: 15.0, radius: 125.0)
    var configMagX = ConfigArray(minimumValue: -100.0, maximumValue: 100.0, totalValue: 200.0, step: 1.0,  knobRadius: 15.0, radius: 125.0)
    var configMagY = ConfigArray(minimumValue: -100.0, maximumValue: 100.0, totalValue: 200.0, step: 1.0,  knobRadius: 15.0, radius: 125.0)
    var configMagZ = ConfigArray(minimumValue: -100.0, maximumValue: 100.0, totalValue: 200.0, step: 1.0,  knobRadius: 15.0, radius: 125.0)
   
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
                        DynamicMapView(isRandom: $isRandom, isGeolocation: $isGeolocation, geometry: geometry)
                            .frame(width: geometry.size.width * 0.92, height: geometry.size.height * 0.3)
                            .padding(.top, geometry.size.height * 0.01)
                    }
                    .cornerRadius(geometry.size.height * 0.005)
                    .shadow(radius: 5)
                    .padding(.top, geometry.size.height * 0.01)
                    
                    VStack {
                        HStack {
                            HStack {
                                Text("Heart Rate")
                                    .font(.system(size: geometry.size.height * 0.016, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                
                                
                                Text("\(Int(heartRate)) BPM")
                                    .font(.system(size: geometry.size.height * 0.016, weight: .semibold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                    .padding(.leading, geometry.size.width * 0.01)
                            }
                            .padding(.vertical, geometry.size.height * 0.008)
                            
                            Spacer()
                            
                            HStack(alignment: .center, spacing: 0) {
                                Spacer()
                                Circle()
                                    .foregroundColor(heartRateColor(heartRate))
                                    .frame(width: geometry.size.width * 0.018, height: geometry.size.height * 0.018)
                                    .padding(.trailing, geometry.size.width * 0.02)
                                Text("\(heartRateRisk(heartRate))")
                                    .foregroundColor(heartRateColor(heartRate))
                                    .font(.system(size: geometry.size.height * 0.016, weight: .semibold))
                                    .padding(.trailing, geometry.size.width * 0.02)
                                    
                            }
                            .padding(.vertical, geometry.size.height * 0.008)
                        }
                        
                        Slider(value: $heartRate, in: 20...220, step: 1)
                            .accentColor(Color(hex: 0x2A0862))
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(geometry.size.height * 0.005)
                    .shadow(radius: 5)
                    .frame(width: geometry.size.width * 0.92)
                    .padding(.top, geometry.size.height * 0.01)
                    
                    VStack {
                        HStack {
                            HStack {
                                Text("Respiration Rate")
                                    .font(.system(size: geometry.size.height * 0.016, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                
                                
                                Text("\(Int(respirationRate)) BrPM")
                                    .font(.system(size: geometry.size.height * 0.016, weight: .semibold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                    .padding(.leading, geometry.size.width * 0.01)
                            }
                            .padding(.vertical, geometry.size.height * 0.008)
                            
                            Spacer()
                            
                            HStack(alignment: .center, spacing: 0) {
                                Spacer()
                                Circle()
                                    .foregroundColor(respirationRateColor(respirationRate))
                                    .frame(width: geometry.size.width * 0.018, height: geometry.size.height * 0.018)
                                    .padding(.trailing, geometry.size.width * 0.02)
                                
                                Text("\(respirationRateRisk(respirationRate))")
                                    .foregroundColor(respirationRateColor(respirationRate))
                                    .font(.system(size: geometry.size.height * 0.016, weight: .semibold))
                                    .padding(.trailing, geometry.size.width * 0.02)
                            }
                            .padding(.vertical, geometry.size.height * 0.008)
                            
                            Spacer()
                        }
                        
                        Slider(value: $respirationRate, in: 0...20, step: 1)
                            .accentColor(Color(hex: 0x2A0862))
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(geometry.size.height * 0.005)
                    .shadow(radius: 5)
                    .frame(width: geometry.size.width * 0.92)
                    .padding(.top, geometry.size.height * 0.01)
                    
                    VStack {
                        HStack {
                            HStack {
                                Text("Device Battery")
                                    .font(.system(size: geometry.size.height * 0.016, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                
                                
                                Text("\(Int(deviceBattery))%")
                                    .font(.system(size: geometry.size.height * 0.016, weight: .semibold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                    .padding(.leading, geometry.size.width * 0.01)
                            }
                            .padding(.vertical, geometry.size.height * 0.008)
                            
                            Spacer()
                            
                            HStack(alignment: .center, spacing: 0) {
                                Spacer()
                                Circle()
                                    .foregroundColor(batteryLevelColor(deviceBattery))
                                    .frame(width: geometry.size.width * 0.018, height: geometry.size.height * 0.018)
                                    .padding(.trailing, geometry.size.width * 0.02)
                                
                                Text("\(batteryLevelRisk(deviceBattery))")
                                    .foregroundColor(batteryLevelColor(deviceBattery))
                                    .font(.system(size: geometry.size.height * 0.016, weight: .semibold))
                                    .padding(.trailing, geometry.size.width * 0.02)
                            }
                            .padding(.vertical, geometry.size.height * 0.008)
                            
                        }
                        
                        Slider(value: $deviceBattery, in: 0...100, step: 1)
                            .accentColor(Color(hex: 0x2A0862))
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(geometry.size.height * 0.005)
                    .shadow(radius: 5)
                    .frame(width: geometry.size.width * 0.92)
                    .padding(.top, geometry.size.height * 0.01)
                        
                    
                    HStack {
                        VStack {
                            HStack {
                                Spacer()
                                Text("Accelerometer")
                                    .font(.system(size: geometry.size.height * 0.016, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                Spacer()
                            }
                            
                            VStack {
                                HStack {
                                    Spacer()
                                    MotionSensorGauge(motionValue: $accX, configArray: configAccX, motionVector: "X", motionUnit: "g")
                                        .frame(width: geometry.size.width * 0.14, height: geometry.size.height * 0.14)
                                        .padding(.top, geometry.size.height * 0.01)
                                    Spacer()
                                }
                                HStack {
                                    Spacer()
                                    MotionSensorGauge(motionValue: $accY, configArray: configAccY, motionVector: "Y", motionUnit: "g")
                                        .frame(width: geometry.size.width * 0.14, height: geometry.size.height * 0.14)
                                        .padding(.top, geometry.size.height * 0.01)
                                    Spacer()
                                }
                                HStack {
                                    Spacer()
                                    MotionSensorGauge(motionValue: $accZ, configArray: configAccZ, motionVector: "Z", motionUnit: "g")
                                        .frame(width: geometry.size.width * 0.14, height: geometry.size.height * 0.14)
                                        .padding(.top, geometry.size.height * 0.01)
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(geometry.size.height * 0.005)
                        .shadow(radius: 5)
                        
                        VStack {
                            HStack {
                                Spacer()
                                Text("Gyroscope")
                                    .font(.system(size: geometry.size.height * 0.016, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                Spacer()
                            }
                            
                            VStack {
                                HStack {
                                    Spacer()
                                    MotionSensorGauge(motionValue: $gyroX, configArray: configGyroX, motionVector: "X", motionUnit: "°")
                                        .frame(width: geometry.size.width * 0.14, height: geometry.size.height * 0.14)
                                        .padding(.top, geometry.size.height * 0.01)
                                    Spacer()
                                }
                                HStack {
                                    Spacer()
                                    MotionSensorGauge(motionValue: $gyroY, configArray: configGyroY, motionVector: "Y", motionUnit: "°")
                                        .frame(width: geometry.size.width * 0.14, height: geometry.size.height * 0.14)
                                        .padding(.top, geometry.size.height * 0.01)
                                    Spacer()
                                }
                                HStack {
                                    Spacer()
                                    MotionSensorGauge(motionValue: $gyroZ, configArray: configGyroZ, motionVector: "Z", motionUnit: "°")
                                        .frame(width: geometry.size.width * 0.14, height: geometry.size.height * 0.14)
                                        .padding(.top, geometry.size.height * 0.01)
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(geometry.size.height * 0.005)
                        .shadow(radius: 5)
                        
                        VStack {
                            HStack {
                                Spacer()
                                Text("Magnetometer")
                                    .font(.system(size: geometry.size.height * 0.016, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                Spacer()
                            }
                            
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    MotionSensorGauge(motionValue: $magX, configArray: configMagX, motionVector: "X", motionUnit: "µT")
                                        .frame(width: geometry.size.width * 0.14, height: geometry.size.height * 0.14)
                                        .padding(.top, geometry.size.height * 0.01)
                                    Spacer()
                                }
                                HStack {
                                    Spacer()
                                    MotionSensorGauge(motionValue: $magY, configArray: configMagY, motionVector: "Y", motionUnit: "µT")
                                        .frame(width: geometry.size.width * 0.14, height: geometry.size.height * 0.14)
                                        .padding(.top, geometry.size.height * 0.01)
                                    Spacer()
                                }
                                HStack {
                                    Spacer()
                                    MotionSensorGauge(motionValue: $magZ, configArray: configMagZ, motionVector: "Z", motionUnit: "µT")
                                        .frame(width: geometry.size.width * 0.14, height: geometry.size.height * 0.14)
                                        .padding(.top, geometry.size.height * 0.01)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(geometry.size.height * 0.005)
                        .shadow(radius: 5)
                    }
                    .frame(width: geometry.size.width * 0.92)
                    .padding(.top, geometry.size.height * 0.01)
                }
                .frame(height: geometry.size.height * 0.82)
                .frame(width: geometry.size.width * 1.0)
                .onAppear {
                    if isMotion {
                        startMotionDataCollection()
                    }
                    
                    if isHealth {
                        startHealthDataCollection()
                    }
                }
                .onDisappear {
                    if isMotion {
                        motionTimer?.cancel()
                    }
                    
                    if isHealth {
                        healthTimer?.cancel()
                    }
                }
                
               
                Spacer()
                
                HStack(alignment: .center) {
                    HStack(alignment: .center) {
                        Toggle("", isOn: $isRandom)
                            .tint(Color(hex: 0x2A0862))
                            .labelsHidden()
                            .padding(.leading, geometry.size.width * 0.01)
                        
                        Text("\(isRandom ? "Randomized Values" : "Constant Values")")
                            .font(.system(size: geometry.size.height * 0.014, weight: .semibold))
                            .foregroundColor(Color.white)
                            .opacity(0.8)
                            .padding(.leading, geometry.size.width * 0.01)
                    }
                    .padding(.leading, geometry.size.width * 0.01)
                    .padding(.top, geometry.size.height * 0.014)
                    .padding(.bottom, geometry.size.height * 0.01)
                    
                    Spacer()
                    
                    HStack {
                        
                        VStack {
                            Button(action: {
                                self.currentView = .SettingsSim
                            }) {
                                Image(systemName: "gear")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: geometry.size.height * 0.022)
                                    .foregroundColor(Color.white)
                                    .shadow(color: .gray.opacity(0.5), radius: 3, x: 0, y: 0)
                                    .padding(.leading, geometry.size.width * 0.01)
                            }
                            
                            Text("Settings")
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
        }
    }
    private func heartRateColor(_ rate: Double) -> Color {
        switch rate {
        case 20...60:
            return .blue
        case 61...100:
            return .green
        case 101...130:
            return .yellow
        case 131...220:
            return .red
        default:
            return .black
        }
    }
    private func heartRateRisk(_ rate: Double) -> String {
        switch rate {
        case 20...60:
            return "Low"
        case 61...100:
            return "Normal"
        case 101...130:
            return "Elevated"
        case 131...220:
            return "Significantly Elevated"
        default:
            return "Normal"
        }
    }
    private func respirationRateColor(_ rate: Double) -> Color {
        switch rate {
        case 0...8:
            return .blue
        case 9...14:
            return .green
        case 15...17:
            return .yellow
        case 18...20:
            return .red
        default:
            return .black
        }
    }
    private func respirationRateRisk(_ rate: Double) -> String {
        switch rate {
        case 0...8:
            return "Low"
        case 9...14:
            return "Normal"
        case 15...17:
            return "Elevated"
        case 18...20:
            return "Significantly Elevated"
        default:
            return "Normal"
        }
    }
    private func batteryLevelColor(_ rate: Double) -> Color {
        switch rate {
        case 0...20:
            return .red
        case 21...100:
            return .green
        default:
            return .black
        }
    }
    private func batteryLevelRisk(_ rate: Double) -> String {
        switch rate {
        case 0...20:
            return "Low"
        case 21...100:
            return "Charged"
        default:
            return "Normal"
        }
    }
    private func startMotionDataCollection() {
        motionTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
            collectMotionData()
            if motionDataCollection.count >= motionFrequency {
                sendMotionData()
                motionDataCollection.removeAll()
            }
        }
    }
    private func collectMotionData() {
        let timestamp = motionDataCollection.count + 1
        
        let motionData: [String: Any] = [
            "accelerometer": [
                "x": Double(accX),
                "y": Double(accY),
                "z": Double(accZ)
            ],
            "gyroscope": [
                "x": Double(gyroX),
                "y": Double(gyroY),
                "z": Double(gyroZ)
            ],
            "magnetometer": [
                "x": Double(magX),
                "y": Double(magY),
                "z": Double(magZ)
            ],
            "timestamp": timestamp
        ]

        motionDataCollection.append(motionData)
    }
    private func sendMotionData() {
        guard let url = URL(string: "http://172.20.10.2:5000/motion-data") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "deviceID": "awse-1000",
            "orgID": authenticatedOrgID,
            "data": motionDataCollection
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            print("Failed to serialize motion data: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error sending motion data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Motion data sent successfully")
            } else {
                print("Failed to send motion data, received non-200 response")
            }
        }.resume()
    }
    private func startHealthDataCollection() {
        healthTimer = Timer.publish(every: healthFrequency, on: .main, in: .common).autoconnect().sink { _ in
            sendHealthData()
        }
    }
    private func sendHealthData() {
        let healthData = [
            "deviceID": "awse-10000",
            "orgID": authenticatedOrgID,
            "heartRate": !isRandom ? heartRate : Int(Double.random(in: Double(heartRate + hrLowerBound)...Double(heartRate + hrUpperBound))),
            "respirationRate": !isRandom ? respirationRate : Int(Double.random(in: Double(respirationRate + respLowerBound)...Double(respirationRate + respUpperBound))),
            "batteryLevel": deviceBattery / 100,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ] as [String: Any]

        guard let url = URL(string: "http://172.20.10.2:5000/health-data") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: healthData, options: [])
        } catch {
            print("Failed to serialize health data: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error sending health data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Health data sent successfully")
            } else {
                print("Failed to send health data, received non-200 response")
            }
        }.resume()
    }
    private func getRandomizedValue(value: CGFloat, range: CGFloat) -> Double {
        if isRandom {
            return Double.random(in: (value - range)...(value + range))
        } else {
            return Double(value)
        }
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0x00FF00) >> 8) / 255.0
        let blue = Double(hex & 0x0000FF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}

extension ISO8601DateFormatter {
    static var shared: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)  // Set the formatter to UTC
        return formatter
    }()
}



