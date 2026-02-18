import SwiftUI
import Observation
import MapKit

@Observable class LocationsViewModel {
    
    //Все загруженные местоположение
    var locations: [Location]
    
    //Текущие место нахождения
    var mapLocations: Location {
        didSet {
            updateMapRedion(location: mapLocations)
        }
    }
    
    var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    
    init() {
        let locations = LocationsDataService.locations
        self.locations = locations
        self.mapLocations = locations.first!
        self.updateMapRedion(location: locations.first!)
    }
    
    private func updateMapRedion(location: Location) {
        withAnimation(.easeInOut) {
            mapRegion = MKCoordinateRegion(
                center: location.coordinates,
                span: mapSpan)
        }
    }
}

