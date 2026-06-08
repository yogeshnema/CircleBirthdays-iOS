import CoreLocation
import Contacts
import MapKit
import SwiftUI

struct PickedAddress {
    let address: String
    let latitude: Double?
    let longitude: Double?
}

struct AddressPickerView: View {
    let initialAddress: String
    let initialCoordinate: CLLocationCoordinate2D?
    let language: AppLanguage
    let onSelect: (PickedAddress) -> Void
    let onCancel: () -> Void

    @State private var searchText = ""
    @State private var selectedAddress: String
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var cameraPosition: MapCameraPosition
    @State private var searchResults: [MKMapItem] = []
    @State private var isResolving = false
    @State private var statusMessage: String?
    @State private var shouldIgnoreNextCameraChange: Bool
    @State private var locationManager = LocationPermissionManager()

    init(
        initialAddress: String,
        initialCoordinate: CLLocationCoordinate2D?,
        language: AppLanguage,
        onSelect: @escaping (PickedAddress) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.initialAddress = initialAddress
        self.initialCoordinate = initialCoordinate
        self.language = language
        self.onSelect = onSelect
        self.onCancel = onCancel

        let trimmedInitialAddress = initialAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        let fallbackCoordinate = CLLocationCoordinate2D(latitude: 22.9734, longitude: 78.6569)
        let coordinate = initialCoordinate ?? fallbackCoordinate
        let span = initialCoordinate == nil
            ? MKCoordinateSpan(latitudeDelta: trimmedInitialAddress.isEmpty ? 18.0 : 8.0, longitudeDelta: trimmedInitialAddress.isEmpty ? 18.0 : 8.0)
            : MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015)
        _selectedAddress = State(initialValue: initialAddress)
        _selectedCoordinate = State(initialValue: initialCoordinate)
        _cameraPosition = State(initialValue: .region(MKCoordinateRegion(center: coordinate, span: span)))
        _searchText = State(initialValue: trimmedInitialAddress)
        _shouldIgnoreNextCameraChange = State(initialValue: true)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBox
                    .padding(16)

                ZStack {
                    Map(position: $cameraPosition) {
                        if let selectedCoordinate {
                            Marker(selectedAddress.isEmpty ? "Selected Location" : selectedAddress, coordinate: selectedCoordinate)
                                .tint(.red)
                        }
                    }
                    .mapControls {
                        MapUserLocationButton()
                        MapCompass()
                    }
                    .onMapCameraChange(frequency: .onEnd) { context in
                        if shouldIgnoreNextCameraChange {
                            shouldIgnoreNextCameraChange = false
                            return
                        }

                        guard !isResolving else { return }
                        selectedCoordinate = context.region.center
                        Task {
                            await reverseGeocode(context.region.center)
                        }
                    }

                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(.red, .white)
                        .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
                        .allowsHitTesting(false)
                }
                .frame(maxHeight: .infinity)

                selectedLocationCard
            }
            .navigationTitle(language == .hindi ? "स्थान चुनें" : "Choose Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(language == .hindi ? "रद्द करें" : "Cancel", action: onCancel)
                }
            }
            .task {
                await resolveInitialAddressIfNeeded()
            }
            .onChange(of: locationManager.currentLocation) { _, newLocation in
                guard let coordinate = newLocation?.coordinate else { return }
                selectedCoordinate = coordinate
                moveCamera(to: coordinate)
                Task {
                    await reverseGeocode(coordinate)
                }
            }
        }
    }

    private var searchBox: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField(language == .hindi ? "स्थान खोजें..." : "Search location...", text: $searchText)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.search)
                    .onSubmit {
                        Task { await searchLocation() }
                    }
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        searchResults = []
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .background(Color.black.opacity(0.05), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            HStack {
                Button {
                    locationManager.requestLocation()
                } label: {
                    Label(language == .hindi ? "मेरा स्थान" : "Locate Me", systemImage: "location.fill")
                }
                .buttonStyle(.bordered)

                Spacer()

                Button {
                    Task { await searchLocation() }
                } label: {
                    Label(language == .hindi ? "खोजें" : "Search", systemImage: "arrow.right.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .disabled(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            if !searchResults.isEmpty {
                VStack(spacing: 0) {
                    ForEach(searchResults.prefix(4), id: \.self) { item in
                        Button {
                            selectMapItem(item)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.name ?? "Location")
                                    .font(.subheadline.weight(.semibold))
                                Text(item.placemark.title ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(.plain)
                        Divider()
                    }
                }
                .padding(.horizontal, 12)
                .background(.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
            }

            if let statusMessage {
                Text(statusMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var selectedLocationCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(language == .hindi ? "चुना गया स्थान" : "Selected Location")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.brown)

            if isResolving {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text(selectedAddress.isEmpty ? (language == .hindi ? "खोज रहे हैं..." : "Locating...") : selectedAddress)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button {
                onSelect(PickedAddress(address: selectedAddress, latitude: selectedCoordinate?.latitude, longitude: selectedCoordinate?.longitude))
            } label: {
                Text(language == .hindi ? "स्थान की पुष्टि करें" : "Confirm Location")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isResolving)
        }
        .padding(16)
        .background(.white)
        .shadow(color: .black.opacity(0.10), radius: 10, y: -3)
    }

    private func resolveInitialAddressIfNeeded() async {
        guard initialCoordinate == nil, !initialAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        await searchLocation(shouldPopulateResults: false)
    }

    private func searchLocation(shouldPopulateResults: Bool = true) async {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }

        isResolving = true
        statusMessage = nil
        defer { isResolving = false }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        if shouldPopulateResults, let selectedCoordinate {
            request.region = MKCoordinateRegion(center: selectedCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.35, longitudeDelta: 0.35))
        }

        do {
            let response = try await MKLocalSearch(request: request).start()
            searchResults = shouldPopulateResults ? response.mapItems : []
            if !shouldPopulateResults, let first = response.mapItems.first {
                selectMapItem(first)
            } else if response.mapItems.isEmpty {
                statusMessage = language == .hindi ? "स्थान नहीं मिला।" : "No location found."
            }
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func selectMapItem(_ item: MKMapItem) {
        let coordinate = item.placemark.coordinate
        selectedCoordinate = coordinate
        selectedAddress = formattedAddress(from: item.placemark)
        moveCamera(to: coordinate)
        searchResults = []
        statusMessage = nil
    }

    private func moveCamera(to coordinate: CLLocationCoordinate2D) {
        shouldIgnoreNextCameraChange = true
        cameraPosition = .region(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)))
    }

    private func reverseGeocode(_ coordinate: CLLocationCoordinate2D) async {
        isResolving = true
        defer { isResolving = false }

        do {
            let placemarks = try await CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
            if let placemark = placemarks.first {
                selectedAddress = formattedAddress(from: placemark)
            }
        } catch {
            statusMessage = error.localizedDescription
        }
    }

    private func formattedAddress(from placemark: MKPlacemark) -> String {
        formattedAddress(from: placemark as CLPlacemark)
    }

    private func formattedAddress(from placemark: CLPlacemark) -> String {
        if let postalAddress = placemark.postalAddress {
            return CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress)
                .replacingOccurrences(of: "\n", with: ", ")
        }

        return [
            placemark.name,
            placemark.subLocality,
            placemark.locality,
            placemark.administrativeArea,
            placemark.country
        ]
        .compactMap { $0 }
        .filter { !$0.isEmpty }
        .joined(separator: ", ")
    }
}

@Observable
final class LocationPermissionManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var currentLocation: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            break
        @unknown default:
            break
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {}
}
