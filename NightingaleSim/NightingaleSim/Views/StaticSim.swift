//
//  StaticSim.swift
//  NightingaleSim
//
//  Created by Peter Iacobelli on 5/10/24.
//
import SwiftUI
import MapKit

struct DraggablePin: Identifiable {
    let id = UUID()
    var location: CLLocationCoordinate2D
}

struct DynamicMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var pin = DraggablePin(location: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437))
    @State private var searchText = ""
    @State private var suggestions: [String] = []
    @State private var showSuggestions = false
    let geometry: GeometryProxy

    var body: some View {
        VStack {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: [pin]) { pin in
                    MapAnnotation(coordinate: pin.location) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 20, height: 20)
                    }
                }
                
                VStack {
                    TextField("Enter address", text: $searchText, onEditingChanged: { isEditing in
                        self.showSuggestions = isEditing
                    }, onCommit: {
                        geocodeAddressString(searchText)
                    })
                    .foregroundColor(Color.white)
                    .background(
                        Color.black  // Background color applied within the padding
                    )
                    .frame(width: geometry.size.width * 0.92)  // Control width separately
                    .overlay(
                        RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 1)  // Adds a border
                    )
                    .shadow(color: .gray.opacity(0.5), radius: 3, x: 0, y: 0)
                    .padding(.top, geometry.size.height * 0.02)
                    .onChange(of: searchText) { newValue in
                        fetchSuggestions(query: newValue)
                    }
                    
                    if !showSuggestions {
                        Spacer()
                    }
                    
                    if showSuggestions {
                        List(suggestions, id: \.self) { suggestion in
                            VStack(spacing: 0) {
                                GeometryReader { geometry in
                                    HStack(alignment: .center) {
                                        Text(suggestion)
                                            .multilineTextAlignment(.leading)
                                            .font(.system(size: geometry.size.height * 0.4, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(width: geometry.size.width, alignment: .leading)
                                            .padding(.leading, geometry.size.width * 0.04)
                                            .padding(.vertical, geometry.size.height * 0.4)
                                    }
                                    .background(Color.clear)
                                }
                                Divider()
                                    .background(Color.white)
                            }
                            .onTapGesture {
                                self.searchText = suggestion
                                self.showSuggestions = false
                                self.geocodeAddressString(suggestion)
                            }
                            .listRowBackground(Color.clear)
                            .listRowInsets(EdgeInsets())
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.black)
                        .frame(width: geometry.size.width * 0.92, height: geometry.size.height * 0.2)
                    }
                }
            }
        }
    }

    private func geocodeAddressString(_ address: String) {
        let urlString = "https://nominatim.openstreetmap.org/search?format=json&q=\(address)&limit=1"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching geocode: \(error?.localizedDescription ?? "")")
                return
            }
            
            if let results = try? JSONDecoder().decode([NominatimResult].self, from: data), let firstResult = results.first,
               let latitude = Double(firstResult.lat), let longitude = Double(firstResult.lon) {
                DispatchQueue.main.async {
                    withAnimation {
                        let newLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        self.region.center = newLocation
                        self.region.span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        self.pin.location = newLocation
                    }
                }
            } else {
                print("Failed to decode suggestions or convert coordinates")
            }
        }.resume()
    }

    
    private func fetchSuggestions(query: String) {
        let urlString = "https://nominatim.openstreetmap.org/search?format=json&q=\(query)&limit=5"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching suggestions: \(error?.localizedDescription ?? "")")
                return
            }
            
            if let results = try? JSONDecoder().decode([NominatimResult].self, from: data) {
                DispatchQueue.main.async {
                    self.suggestions = results.map { $0.display_name }
                    print(self.suggestions)  // Debug: Check what suggestions are received
                }
            } else {
                print("Failed to decode suggestions")
            }
        }.resume()
    }

}

struct NominatimResult: Codable {
    let display_name: String
    let lat: String
    let lon: String
}

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
                    .frame(width: size * 0.1, height: size * 0.1)
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
    
    let gradient = LinearGradient(
        gradient: Gradient(colors: [Color(hex: 0x381A68), Color(hex: 0x5B4D72)]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
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
                    
                    VStack {
                        HStack {
                            HStack {
                                Text("Heart Rate")
                                    .font(.system(size: geometry.size.height * 0.02, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                
                                
                                Text("\(Int(heartRate)) BPM")
                                    .font(.system(size: geometry.size.height * 0.018, weight: .semibold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                    .padding(.leading, geometry.size.width * 0.01)
                            }
                            .padding(.vertical, geometry.size.height * 0.005)
                            
                            Spacer()
                            
                            HStack(alignment: .center, spacing: 0) {
                                Spacer()
                                Circle()
                                    .foregroundColor(heartRateColor(heartRate))
                                    .frame(width: geometry.size.width * 0.02, height: geometry.size.height * 0.02)
                                    .padding(.trailing, geometry.size.width * 0.02)
                                Text("\(heartRateRisk(heartRate))")
                                    .foregroundColor(heartRateColor(heartRate))
                                    .font(.system(size: geometry.size.height * 0.018, weight: .semibold))
                                    .padding(.trailing, geometry.size.width * 0.02)
                                    
                            }
                            .padding(.vertical, geometry.size.height * 0.005)
                        }
                        
                        Slider(value: $heartRate, in: 20...220, step: 1)
                            .accentColor(Color(hex: 0x2A0862))
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .frame(width: geometry.size.width * 0.92)
                    .padding(.top, geometry.size.height * 0.02)
                    
                    VStack {
                        HStack {
                            HStack {
                                Text("Respiration Rate")
                                    .font(.system(size: geometry.size.height * 0.02, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                
                                
                                Text("\(Int(respirationRate)) BrPM")
                                    .font(.system(size: geometry.size.height * 0.018, weight: .semibold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                    .padding(.leading, geometry.size.width * 0.01)
                            }
                            .padding(.vertical, geometry.size.height * 0.005)
                            
                            Spacer()
                            
                            HStack(alignment: .center, spacing: 0) {
                                Spacer()
                                Circle()
                                    .foregroundColor(respirationRateColor(respirationRate))
                                    .frame(width: geometry.size.width * 0.02, height: geometry.size.height * 0.02)
                                    .padding(.trailing, geometry.size.width * 0.02)
                                
                                Text("\(respirationRateRisk(respirationRate))")
                                    .foregroundColor(respirationRateColor(respirationRate))
                                    .font(.system(size: geometry.size.height * 0.018, weight: .semibold))
                                    .padding(.trailing, geometry.size.width * 0.02)
                            }
                            .padding(.vertical, geometry.size.height * 0.005)
                            
                            Spacer()
                        }
                        
                        Slider(value: $respirationRate, in: 0...20, step: 1)
                            .accentColor(Color(hex: 0x2A0862))
                    }
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .frame(width: geometry.size.width * 0.92)
                    .padding(.top, geometry.size.height * 0.02)
                    
                    HStack {
                        VStack {
                            HStack {
                                HStack {
                                    Text("Device Battery")
                                        .font(.system(size: geometry.size.height * 0.02, weight: .bold))
                                        .foregroundColor(Color.white)
                                        .opacity(0.8)
                                    
                                    
                                    Text("\(Int(deviceBattery))%")
                                        .font(.system(size: geometry.size.height * 0.018, weight: .semibold))
                                        .foregroundColor(Color.white)
                                        .opacity(0.8)
                                        .padding(.leading, geometry.size.width * 0.01)
                                }
                                .padding(.vertical, geometry.size.height * 0.005)
                                
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
                                    .font(.system(size: geometry.size.height * 0.02, weight: .bold))
                                    .foregroundColor(Color.white)
                                    .opacity(0.8)
                                
                                Spacer()
                            }
                            .padding(.vertical, geometry.size.height * 0.005)
                            
                            HStack {
                                HStack {
                                    Toggle("", isOn: $isConnected)
                                        .tint(Color(hex: 0x2A0862))
                                        .labelsHidden()
                                    
                                    Text("\(isConnected ? "Connected" : "Disconnected")")
                                        .font(.system(size: geometry.size.height * 0.018, weight: .semibold))
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
                    .frame(width: geometry.size.width * 0.92)
                    .padding(.top, geometry.size.height * 0.02)
                    
                    HStack {
                        DynamicMapView(geometry: geometry)
                            .frame(width: geometry.size.width * 0.92, height: geometry.size.height * 0.3)
                    }
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    
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
                    .frame(width: geometry.size.width * 0.92)
                    .padding(.top, geometry.size.height * 0.02)
                }
                .frame(height: geometry.size.height * 0.86)
                .frame(width: geometry.size.width * 1.0)
                
               
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


