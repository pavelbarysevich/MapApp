import SwiftUI
import MapKit

struct LocationsView: View {
    
    
    @Environment(LocationsViewModel.self) private var vm: LocationsViewModel
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        
        @Bindable var vm = vm
        
        ZStack {
            mapLayer
           
            VStack (spacing: 0) {
                
                header
                    .padding()
                
                Spacer()
                
                locationsPreviewStack
            }
        }
        .sheet(item: $vm.sheetLocation, onDismiss: nil) { location in
            LocationDetailView(location: location)
        }
    }
    
    private var mapLayer: some View {
        Map(position: $cameraPosition) {
            ForEach(vm.locations) { location in
                Annotation(location.name, coordinate: location.coordinates) {
                    LocationMapAnnotationView()
                        .scaleEffect(vm.mapLocation == location ? 1 : 0.7)
                        .shadow(radius: 10)
                        .onTapGesture {
                            vm.showNextLocation(location: location)
                        }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            let center = vm.mapRegion.center
            let closeSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let closeRegion = MKCoordinateRegion(center: center, span: closeSpan)
            cameraPosition = .region(closeRegion)
        }
        .onChange(of: RegionProxy(vm.mapRegion)) { _, _ in
            withAnimation(.easeInOut) {
                let center = vm.mapRegion.center
                let closeSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let closeRegion = MKCoordinateRegion(center: center, span: closeSpan)
                cameraPosition = .region(closeRegion)
            }
        }
    }
    private var locationsPreviewStack: some View {
        ZStack {
            ForEach(vm.locations) { location in
                if vm.mapLocation == location {
                    LocationPreviewView(location: location)
                        .shadow(color: .black.opacity(0.3), radius: 20)
                        .padding()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)))
                }
            }
        }
    }
}

#Preview {
    LocationsView()
        .environment(LocationsViewModel())
}

private struct RegionProxy: Equatable {
    let latitude: Double
    let longitude: Double
    let latDelta: Double
    let lonDelta: Double

    init(_ region: MKCoordinateRegion) {
        latitude = region.center.latitude
        longitude = region.center.longitude
        latDelta = region.span.latitudeDelta
        lonDelta = region.span.longitudeDelta
    }
}

extension LocationsView {
    private var header: some View {
        VStack {
            
            Button {
                vm.toggleLocationsList()
            } label: {
                Text(vm.mapLocation.name + ", " + vm.mapLocation.cityName)
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundStyle(.wOne)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .leading) {
                        Image(systemName: "arrow.down")
                            .font(.headline)
                            .foregroundStyle(.wOne)
                            .padding()
                            .rotationEffect(Angle(degrees: vm.showLocationsList ? 180 : 0))
                    }
            }

            
            if vm.showLocationsList {
                LocationsListView()
            }
            
        }
        .background(.thinMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 15)
    }
}


