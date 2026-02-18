import SwiftUI
import MapKit

struct LocationsView: View {
    
    @Environment(LocationsViewModel.self) private var vm: LocationsViewModel
    
    var body: some View {
        ZStack {
            Map(initialPosition: .region(vm.mapRegion))
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }

    }
}

#Preview {
    LocationsView()
        .environment(LocationsViewModel())
}
