//
//  StaticSim.swift
//  NightingaleSim
//
//  Created by Peter Iacobelli on 5/10/24.
//

import SwiftUI

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
            let mainStrokeWidth = size * 0.03
            ZStack {
                Circle()
                    .frame(width: size, height: size)
                    .foregroundColor(.clear)  // Set the main circle background to transparent
                Circle()
                    .stroke(Color.gray, style: strokeStyle)
                    .frame(width: size, height: size)
                Circle()
                    .trim(from: 0.0, to: motionValue / configArray.totalValue)
                    .stroke(motionValue < configArray.maximumValue / 2 ? Color.blue : Color.red, lineWidth: mainStrokeWidth)
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
                Circle()
                    .fill(motionValue < configArray.maximumValue / 2 ? Color.blue : Color.red)
                    .frame(width: size * 0.1, height: size * 0.1)
                    .offset(y: -(size / 2 - mainStrokeWidth / 2))
                    .rotationEffect(Angle.degrees(Double(angleValue)))
                    .gesture(DragGesture(minimumDistance: 0).onChanged({ value in
                        self.change(location: value.location, in: size)
                    }))
                Text("\(motionVector): \(Int(motionValue)) \(motionUnit)")
                    .font(.system(size: size * 0.2))
                    .foregroundColor(.white)
            }
            .background(Color.clear)
        }
    }

    private func change(location: CGPoint, in size: CGFloat) {
        let vector = CGVector(dx: location.x - size / 2, dy: location.y - size / 2)
        let angle = atan2(vector.dy, vector.dx) + .pi / 2.0
        let fixedAngle = angle < 0.0 ? angle + 2.0 * .pi : angle
        let value = fixedAngle / (2.0 * .pi) * configArray.totalValue
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
    let knobRadius: CGFloat
    let radius: CGFloat
}

struct StaticSim: View {
    @Binding var currentView: AppView
    @Binding var authenticatedUsername: String
    
    let gradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: 0x381A68), Color(hex: 0x5B4D72)]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    @State private var heartRate: Double = 70
    @State private var respirationRate: Double = 12
    @State private var deviceBattery: Double = 85
    @State private var isConnected: Bool = true
    @State private var accX: CGFloat = 0.0
    @State private var accY: CGFloat = 0.0
    @State private var accZ: CGFloat = 0.0
    @State private var gyroX: CGFloat = 0.0
    @State private var gyroY: CGFloat = 0.0
    @State private var gyroZ: CGFloat = 0.0
    @State private var magX: CGFloat = 0.0
    @State private var magY: CGFloat = 0.0
    @State private var magZ: CGFloat = 0.0
    
    var configAccX = ConfigArray(minimumValue: 0.0, maximumValue: 20.0, totalValue: 20.0, knobRadius: 15.0, radius: 125.0)
    var configAccY = ConfigArray(minimumValue: 0.0, maximumValue: 20.0, totalValue: 20.0, knobRadius: 15.0, radius: 125.0)
    var configAccZ = ConfigArray(minimumValue: 0.0, maximumValue: 20.0, totalValue: 20.0, knobRadius: 15.0, radius: 125.0)
    var configGyroX = ConfigArray(minimumValue: 0.0, maximumValue: 20.0, totalValue: 20.0, knobRadius: 15.0, radius: 125.0)
    var configGyroY = ConfigArray(minimumValue: 0.0, maximumValue: 20.0, totalValue: 20.0, knobRadius: 15.0, radius: 125.0)
    var configGyroZ = ConfigArray(minimumValue: 0.0, maximumValue: 20.0, totalValue: 20.0, knobRadius: 15.0, radius: 125.0)
    var configMagX = ConfigArray(minimumValue: 0.0, maximumValue: 20.0, totalValue: 20.0, knobRadius: 15.0, radius: 125.0)
    var configMagY = ConfigArray(minimumValue: 0.0, maximumValue: 20.0, totalValue: 20.0, knobRadius: 15.0, radius: 125.0)
    var configMagZ = ConfigArray(minimumValue: 0.0, maximumValue: 20.0, totalValue: 20.0, knobRadius: 15.0, radius: 125.0)
   
    
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
                            HStack {
                                Text("Heart Rate")
                                    .font(.system(size: geometry.size.height * 0.024, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                
                                
                                Text("\(Int(heartRate)) BPM")
                                    .font(.system(size: geometry.size.height * 0.02, weight: .semibold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                    .padding(.leading, geometry.size.width * 0.01)
                            }
                            
                            HStack {
                                Circle()
                                    .foregroundColor(heartRateColor(heartRate))
                                    .frame(height: geometry.size.height * 0.02)
                                
                                Text("\(heartRateRisk(heartRate))")
                                    .foregroundColor(heartRateColor(heartRate))
                                    .font(.system(size: geometry.size.height * 0.02, weight: .semibold))
                            }
                            .padding(.leading, geometry.size.width * 0.1)
                            
                            Spacer()
                        }
                        
                        Slider(value: $heartRate, in: 20...220, step: 1)
                            .accentColor(Color(hex: 0x2A0862))
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .frame(width: geometry.size.width * 0.96)
                    .padding(.top, geometry.size.height * 0.02)
                    
                    VStack {
                        HStack {
                            HStack {
                                Text("Respiration Rate")
                                    .font(.system(size: geometry.size.height * 0.024, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                
                                
                                Text("\(Int(respirationRate)) BrPM")
                                    .font(.system(size: geometry.size.height * 0.02, weight: .semibold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                    .padding(.leading, geometry.size.width * 0.01)
                            }
                            
                            HStack {
                                Circle()
                                    .foregroundColor(respirationRateColor(respirationRate))
                                    .frame(height: geometry.size.height * 0.02)
                                
                                Text("\(respirationRateRisk(respirationRate))")
                                    .foregroundColor(respirationRateColor(respirationRate))
                                    .font(.system(size: geometry.size.height * 0.02, weight: .semibold))
                            }
                            .padding(.leading, geometry.size.width * 0.1)
                            
                            Spacer()
                        }
                        
                        Slider(value: $respirationRate, in: 0...20, step: 1)
                            .accentColor(Color(hex: 0x2A0862))
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .frame(width: geometry.size.width * 0.96)
                    .padding(.top, geometry.size.height * 0.02)
                    
                    HStack {
                        VStack {
                            HStack {
                                HStack {
                                    Text("Device Battery")
                                        .font(.system(size: geometry.size.height * 0.024, weight: .bold))
                                        .foregroundColor(Color.white)
                                        .opacity(0.8)
                                    
                                    
                                    Text("\(Int(deviceBattery))%")
                                        .font(.system(size: geometry.size.height * 0.02, weight: .semibold))
                                        .foregroundColor(Color.white)
                                        .opacity(0.8)
                                        .padding(.leading, geometry.size.width * 0.01)
                                }
                                
                                Spacer()
                            }
                            
                            Slider(value: $deviceBattery, in: 0...100, step: 1)
                                .accentColor(Color(hex: 0x2A0862))
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        
                        VStack {
                            HStack {
                                Text("Device Presence")
                                    .font(.system(size: geometry.size.height * 0.024, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                
                                Spacer()
                            }
                            
                            HStack {
                                HStack {
                                    Toggle("", isOn: $isConnected)
                                        .tint(Color(hex: 0x2A0862))
                                        .labelsHidden()
                                    
                                    Text("\(isConnected ? "Connected" : "Disconnected")")
                                        .font(.system(size: geometry.size.height * 0.02, weight: .semibold))
                                        .foregroundColor(Color.white)
                                        .opacity(0.8)
                                        .padding(.leading, geometry.size.width * 0.01)
                                }
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .frame(width: geometry.size.width * 0.96)
                    .padding(.top, geometry.size.height * 0.02)
                    
                    HStack {
                        VStack {
                            HStack {
                                Spacer()
                                Text("Accelerometer")
                                    .font(.system(size: geometry.size.height * 0.024, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                Spacer()
                            }
                            
                            VStack {
                                HStack {
                                    Spacer()
                                    MotionSensorGauge(motionValue: $accX, configArray: configAccX, motionVector: "X", motionUnit: "g")
                                        .frame(width: geometry.size.width * 0.14, height: geometry.size.height * 0.14)
                                    Spacer()
                                }
                                HStack {
                                    Spacer()
                                    MotionSensorGauge(motionValue: $accY, configArray: configAccY, motionVector: "Y", motionUnit: "g")
                                        .frame(width: geometry.size.width * 0.14, height: geometry.size.height * 0.14)
                                    Spacer()
                                }
                                HStack {
                                    Spacer()
                                    MotionSensorGauge(motionValue: $accZ, configArray: configAccZ, motionVector: "Z", motionUnit: "g")
                                        .frame(width: geometry.size.width * 0.14, height: geometry.size.height * 0.14)
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        
                        VStack {
                            HStack {
                                Spacer()
                                Text("Gyroscope")
                                    .font(.system(size: geometry.size.height * 0.024, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                Spacer()
                            }
                            
                            VStack {
                                HStack {
                                    Spacer()
                                    MotionSensorGauge(motionValue: $gyroX, configArray: configGyroX, motionVector: "X", motionUnit: "°")
                                        .frame(width: geometry.size.width * 0.14, height: geometry.size.height * 0.14)
                                    Spacer()
                                }
                                HStack {
                                    Spacer()
                                    MotionSensorGauge(motionValue: $gyroY, configArray: configGyroY, motionVector: "Y", motionUnit: "°")
                                        .frame(width: geometry.size.width * 0.14, height: geometry.size.height * 0.14)
                                    Spacer()
                                }
                                HStack {
                                    Spacer()
                                    MotionSensorGauge(motionValue: $gyroZ, configArray: configGyroZ, motionVector: "Z", motionUnit: "°")
                                        .frame(width: geometry.size.width * 0.14, height: geometry.size.height * 0.14)
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        
                        VStack {
                            HStack {
                                Spacer()
                                Text("Magnetometer")
                                    .font(.system(size: geometry.size.height * 0.024, weight: .bold))
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
                                    Spacer()
                                }
                                HStack {
                                    Spacer()
                                    MotionSensorGauge(motionValue: $magY, configArray: configMagY, motionVector: "Y", motionUnit: "µT")
                                        .frame(width: geometry.size.width * 0.14, height: geometry.size.height * 0.14)
                                    Spacer()
                                }
                                HStack {
                                    Spacer()
                                    MotionSensorGauge(motionValue: $magZ, configArray: configMagZ, motionVector: "Z", motionUnit: "µT")
                                        .frame(width: geometry.size.width * 0.14, height: geometry.size.height * 0.14)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    }
                    .frame(width: geometry.size.width * 0.96)
                    .padding(.top, geometry.size.height * 0.02)
                }
                .frame(height: geometry.size.height * 0.86)
                
               
                Spacer()
                
                HStack {
                    
                }
                .frame(width: geometry.size.width * 1.0)
                .edgesIgnoringSafeArea(.all)
                .background(Color.gray)
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
}


extension Color {
    init(hex: UInt, alpha: Double = 1.0) {
        let red = Double((hex & 0xFF0000) >> 16) / 255.0
        let green = Double((hex & 0x00FF00) >> 8) / 255.0
        let blue = Double(hex & 0x0000FF) / 255.0
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
}


