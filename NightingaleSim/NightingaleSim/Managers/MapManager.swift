//
//  MapManager.swift
//  NightingaleSim
//
//  Created by Peter Iacobelli on 5/12/24.
//

import SwiftUI
import MapKit
import Combine

struct LocationPin: Identifiable {
    let id = UUID()
    var location: CLLocationCoordinate2D
}

struct DynamicMapView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 29.559684, longitude: -95.08374),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var pin = LocationPin(location: CLLocationCoordinate2D(latitude: 29.559684, longitude: -95.08374))
    @State private var searchText = ""
    @State private var suggestions: [String] = []
    @State private var showSuggestions = false
    @State private var altitude: Double = 0
    @State private var geolocationTimer: AnyCancellable?
    @Binding var isRandom: Bool
    @Binding var isGeolocation: Bool
    let geometry: GeometryProxy
    

    var body: some View {
        VStack {
            ZStack {
                Map(coordinateRegion: $region, annotationItems: [pin]) { pin in
                    MapAnnotation(coordinate: pin.location) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: geometry.size.width * 0.04, height: geometry.size.height * 0.04)
                    }
                }

                VStack {
                    TextField("Enter address", text: $searchText, onEditingChanged: { isEditing in
                        self.showSuggestions = isEditing
                    }, onCommit: {
                        geocodeAddressString(searchText)
                    })
                    .padding(.horizontal, geometry.size.width * 0.04)
                    .padding(.vertical, geometry.size.height * 0.01)
                    .background(Color(hex: 0x646464))
                    .foregroundColor(Color.white)
                    .font(.system(size: geometry.size.height * 0.02, weight: .regular))
                    .frame(maxWidth: .infinity)
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
                        .background(Color(hex: 0x504F51))
                        .frame(width: geometry.size.width * 0.92, height: geometry.size.height * 0.26)
                        .padding(.top, geometry.size.height * -0.01)
                    }
                }
            }
        }
        .cornerRadius(geometry.size.height * 0.005)
        .onAppear {
            if isGeolocation {
                startGeolocationUpdates()
            }
        }
        .onDisappear {
            if isGeolocation {
                geolocationTimer?.cancel()
            }
        }
    }

    private func startGeolocationUpdates() {
        geolocationTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect().sink { _ in
            fetchAndSendGeolocationData()
        }
    }

    private func fetchAndSendGeolocationData() {
        fetchAltitude(for: pin.location) { altitude in
            self.altitude = altitude ?? 0
            self.sendGeolocationData()
        }
    }

    private func fetchAltitude(for location: CLLocationCoordinate2D, completion: @escaping (Double?) -> Void) {
        let urlString = "https://api.open-elevation.com/api/v1/lookup?locations=\(location.latitude),\(location.longitude)"
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching elevation: \(error?.localizedDescription ?? "")")
                completion(nil)
                return
            }

            if let elevationResponse = try? JSONDecoder().decode(ElevationResult.self, from: data),
               let elevation = elevationResponse.results.first?.elevation {
                DispatchQueue.main.async {
                    completion(elevation)
                }
            } else {
                print("Failed to decode elevation data")
                completion(nil)
            }
        }.resume()
    }


    private func sendGeolocationData() {
        let latValue = getRandomizedValue(value: pin.location.latitude, range: 0.0001)
        let lonValue = getRandomizedValue(value: pin.location.longitude, range: 0.0001)
        let altValue = getRandomizedValue(value: altitude, range: 5)
        let geolocationData = [
            "lat": latValue,
            "lon": lonValue,
            "alt": altValue,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ] as [String : Any]

        guard let url = URL(string: "http://172.20.10.2:5000/geolocation-data") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: geolocationData, options: [])
        } catch {
            print("Failed to serialize geolocation data: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error sending geolocation data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Geolocation data sent successfully")
            } else {
                print("Failed to send geolocation data, received non-200 response")
            }
        }.resume()
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
                    print(self.suggestions)
                }
            } else {
                print("Failed to decode suggestions")
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

struct NominatimResult: Codable {
    let display_name: String
    let lat: String
    let lon: String
}

struct ElevationResult: Codable {
    struct Result: Codable {
        let elevation: Double
        let location: Location
    }

    struct Location: Codable {
        let lat: Double
        let lon: Double
    }

    let results: [Result]
}

