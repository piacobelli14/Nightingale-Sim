//
//  MapManager.swift
//  NightingaleSim
//
//  Created by Peter Iacobelli on 5/12/24.
//

import SwiftUI
import MapKit
import Combine

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
    @Binding var authenticatedOrgID: String
    @Binding var targetDevice: String
    @Binding var isGeolocation: Bool
    @Binding var geolocationFrequency: Int
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
                    .padding(.vertical, geometry.size.height * 0.014)
                    .background(Color(hex: 0x646464))
                    .foregroundColor(Color.white)
                    .font(.system(size: geometry.size.height * 0.012, weight: .regular))
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
        geolocationTimer = Timer.publish(every: TimeInterval(geolocationFrequency), on: .main, in: .common).autoconnect().sink { _ in
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

    private func sendGeolocationData() {
        let latValue = getRandomizedValue(value: pin.location.latitude, range: 0.0001)
        let lonValue = getRandomizedValue(value: pin.location.longitude, range: 0.0001)
        let altValue = getRandomizedValue(value: altitude, range: 5)
        let geolocationData = [
            "deviceID": targetDevice,
            "orgID": authenticatedOrgID,
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
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                return
            } else {
                return
            }
        }.resume()
    }

    private func geocodeAddressString(_ address: String) {
        let urlString = "https://nominatim.openstreetmap.org/search?format=json&q=\(address)&limit=1"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
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
                return
            }
        }.resume()
    }

    private func fetchSuggestions(query: String) {
        let urlString = "https://nominatim.openstreetmap.org/search?format=json&q=\(query)&limit=5"
        guard let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                return
            }

            if let results = try? JSONDecoder().decode([NominatimResult].self, from: data) {
                DispatchQueue.main.async {
                    self.suggestions = results.map { $0.display_name }
                }
            } else {
                return
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

