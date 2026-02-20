import SwiftUI
import Observation
import MapKit

@Observable class LocationsViewModel {
    
    //Все загруженные местоположение
    var locations: [Location]
    
    //Текущие место нахождения
    var mapLocation: Location {
        didSet {
            updateMapRedion(location: mapLocation)
        }
    }
//Вот текущий регион на карте
    var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    
    var showLocationsList: Bool = false
    
    init() {
        let locations = LocationsDataService.locations
        self.locations = locations
        self.mapLocation = locations.first!
        self.updateMapRedion(location: locations.first!)
    }
    
    private func updateMapRedion(location: Location) {
        withAnimation(.easeInOut) {
            mapRegion = MKCoordinateRegion(
                center: location.coordinates,
                span: mapSpan)
        }
    }
    
    func toggleLocationsList() {
        withAnimation(.easeInOut) {
            showLocationsList = !showLocationsList
        }
    }
    
    func showNextLocation(location: Location) {
        withAnimation(.easeInOut) {
            mapLocation = location
            showLocationsList = false
        }
    }
}

