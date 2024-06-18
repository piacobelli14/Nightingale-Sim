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
    @State private var geolocationTimer: AnyCancellable?
    @Binding var isRandom: Bool
    @Binding var authenticatedOrgID: String
    @Binding var targetDevice: String
    @Binding var isGeolocation: Bool
    let geometry: GeometryProxy
    @Binding var locationData: LocationData

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
                fetchInitialAltitude()
                startGeolocationUpdates()
            }
        }
        .onDisappear {
            if isGeolocation {
                geolocationTimer?.cancel()
            }
        }
    }

    private func fetchInitialAltitude() {
        let initialLocation = pin.location
        fetchAltitude(for: initialLocation) { altitude in
            DispatchQueue.main.async {
                self.locationData.altitude = altitude ?? 0
            }
        }
    }

    private func startGeolocationUpdates() {
        geolocationTimer = Timer.publish(every: TimeInterval(1), on: .main, in: .common).autoconnect().sink { _ in
            fetchAndSendGeolocationData()
        }
    }

    private func fetchAndSendGeolocationData() {
        let newLatitude = getRandomizedValue(value: pin.location.latitude, range: 0.001)
        let newLongitude = getRandomizedValue(value: pin.location.longitude, range: 0.001)

        fetchAltitude(for: CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)) { altitude in
            DispatchQueue.main.async {
                self.locationData.latitude = newLatitude
                self.locationData.longitude = newLongitude
                self.locationData.altitude = altitude ?? 0

               
                sendGeolocationData()
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

    private func sendGeolocationData() {
        // No need to send geolocation data separately, it's included in the main payload
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
