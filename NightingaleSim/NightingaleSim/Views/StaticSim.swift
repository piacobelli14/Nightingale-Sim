import SwiftUI
import Combine
import CoreLocation

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

struct StaticSim: View {
    @Binding var currentView: AppView
    @Binding var authenticatedUsername: String
    @Binding var authenticatedOrgID: String
    @Binding var targetDevice: String
    @Binding var isMotion: Bool
    @Binding var isHealth: Bool
    @Binding var isGeolocation: Bool
    @Binding var dataFrequency: Int
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

    @State private var locationData = LocationData(latitude: 29.559684, longitude: -95.08374, altitude: 0)
    @State private var errorMessage: String? = nil

    @State private var deviceInfo: [DeviceInfo] = []
    @State private var availableDevIDs: [String] = []

    @State private var dataTimer: AnyCancellable?
    @State private var dataCollection = [[String: Any]]()

    let gradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: 0x381A68), Color(hex: 0x5B4D72)]),
        startPoint: .leading,
        endPoint: .trailing
    )

    @State private var isRandom: Bool = true
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
                        DynamicMapView(isRandom: $isRandom, authenticatedOrgID: $authenticatedOrgID, targetDevice: $targetDevice, isGeolocation: $isGeolocation, geometry: geometry, locationData: $locationData)
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
                    startDataCollection()
                   
                }
                .onDisappear {
                    dataTimer?.cancel()
               }
                
               
                Spacer()
                
                HStack(alignment: .center) {
                    HStack(alignment: .center) {
                        Toggle("", isOn: $isRandom)
                            .tint(Color(hex: 0x2A0862))
                            .labelsHidden()
                            .padding(.leading, geometry.size.width * 0.01)
                            .onTapGesture {
                                print(isRandom)
                            }
                        
                        Text("\(isRandom ? "Randomized Values" : "Constant Values")")
                            .font(.system(size: geometry.size.height * 0.014, weight: .semibold))
                            .foregroundColor(Color.white)
                            .opacity(0.8)
                            .padding(.leading, geometry.size.width * 0.01)
                    }
                    .padding(.leading, geometry.size.width * 0.01)
                    .padding(.top, geometry.size.height * 0.02)
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
                    .padding(.top, geometry.size.height * 0.02)
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
                getAvailableDevices()
                fetchInitialAltitude()
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
    
    private func startDataCollection() {
        dataTimer = Timer.publish(every: TimeInterval(dataFrequency), on: .main, in: .common).autoconnect().sink { _ in
            collectAndSendData()
        }
    }

    private func collectAndSendData() {
        let timestamp = Date().timeIntervalSince1970

        let singleMotionData: [String: Any] = [
            "accelerometer": [
                "x": isMotion ? (!isRandom ? Double(accX) : Double.random(in: Double(accX + accLowerBound)...Double(accX + accUpperBound))) : Double(0),
                "y": isMotion ? (!isRandom ? Double(accY) : Double.random(in: Double(accY + accLowerBound)...Double(accY + accUpperBound))) : Double(0),
                "z": isMotion ? (!isRandom ? Double(accZ) : Double.random(in: Double(accZ + accLowerBound)...Double(accZ + accUpperBound))) : Double(0)
            ],
            "gyroscope": [
                "x": isMotion ? (!isRandom ? Double(gyroX) : Double.random(in: Double(gyroX + gyroLowerBound)...Double(gyroX + gyroUpperBound))) : Double(0),
                "y": isMotion ? (!isRandom ? Double(gyroY) : Double.random(in: Double(gyroY + gyroLowerBound)...Double(gyroY + gyroUpperBound))) : Double(0),
                "z": isMotion ? (!isRandom ? Double(gyroZ) : Double.random(in: Double(gyroZ + gyroLowerBound)...Double(gyroZ + gyroUpperBound))) : Double(0)
            ],
            "magnetometer": [
                "x": isMotion ? (!isRandom ? Double(magX) : Double.random(in: Double(magX + magLowerBound)...Double(magX + magUpperBound))) : Double(0),
                "y": isMotion ? (!isRandom ? Double(magY) : Double.random(in: Double(magY + magLowerBound)...Double(magY + magUpperBound))) : Double(0),
                "z": isMotion ? (!isRandom ? Double(magZ) : Double.random(in: Double(magZ + magLowerBound)...Double(magZ + magUpperBound))) : Double(0)
            ],
            "heartRate": isHealth ? (!isRandom ? Double(heartRate) : Double.random(in: Double(heartRate + hrLowerBound)...Double(heartRate + hrUpperBound))) : 0,
            "respirationRate": isHealth ? (!isRandom ? Double(respirationRate) : Double.random(in: Double(respirationRate + respLowerBound)...Double(respirationRate + respUpperBound))) : 0,
            "batteryLevel": isHealth ? (deviceBattery / 100) : 0,
            "lat": isGeolocation ? locationData.latitude : 0,
            "lon": isGeolocation ? locationData.longitude : 0,
            "alt": isGeolocation ? locationData.altitude : 0,
            "timestamp": timestamp
        ]

        let payload: [String: Any] = [
            "deviceID": targetDevice,
            "orgID": authenticatedOrgID,
            "data": singleMotionData
        ]
        
        sendPayloadToServer(payload: payload)
    }

    private func sendPayloadToServer(payload: [String: Any]) {
        guard let url = URL(string: "https://vektor-api.vercel.app/api/rt-data") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    return
                }
            }
            
            task.resume()
        } catch {
            return
        }
    }

    private func getAvailableDevices() {
        guard let token = loadTokenFromKeychain() else {
            return
        }

        let requestBody: [String: Any] = [
            "organizationID": authenticatedOrgID
        ]

        let url = URL(string: "https://nightingale-web-api.vercel.app/nightingale/api/get-devices")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received from the server"
                }
                return
            }

            guard let response = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.errorMessage = "Invalid response from the server"
                }
                return
            }

            if response.statusCode == 200 {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])

                    let decodedData = try JSONDecoder().decode(DeviceInfoResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.deviceInfo = decodedData.data
                        self.availableDevIDs = decodedData.data.filter { $0.assignedTo != "None" }.map { $0.devID }
                        self.targetDevice = availableDevIDs.first ?? ""
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.errorMessage = "JSON decoding error: \(error.localizedDescription)"
                    }
                }

            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Server error with status code: \(response.statusCode)"
                }
            }
        }
        .resume()
    }

    private func fetchInitialAltitude() {
        fetchAltitude(for: CLLocationCoordinate2D(latitude: locationData.latitude, longitude: locationData.longitude)) { altitude in
            DispatchQueue.main.async {
                self.locationData.altitude = altitude ?? 0
            }
        }
    }

    private func fetchAltitude(for location: CLLocationCoordinate2D, completion: @escaping (Double?) -> Void) {
        let urlString = "https://api.open-meteo.com/v1/elevation?latitude=\(location.latitude)&longitude=\(location.longitude)&format=json"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let elevationResponse = try JSONDecoder().decode(OpenMeteoElevationResponse.self, from: data)
                if let elevation = elevationResponse.elevation.first {
                    DispatchQueue.main.async {
                        completion(elevation)
                    }
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
}
