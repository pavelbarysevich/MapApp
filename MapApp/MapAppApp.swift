import SwiftUI

@main
struct MapAppApp: App {
    
    @State private var vm = LocationsViewModel()
    
    var body: some Scene {
        WindowGroup {
            LocationsView()
                .environment(vm)
        }
    }
}
