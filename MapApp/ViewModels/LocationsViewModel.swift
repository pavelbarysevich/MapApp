import SwiftUI
import Observation

@Observable class LocationsViewModel {
    
    var locations: [Location]
    
    init() {
        let locations = LocationsDataService.locations
        self.locations = locations
    }
}

