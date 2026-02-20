import SwiftUI
import MapKit

struct LocationsView: View {
    
    @Environment(LocationsViewModel.self) private var vm: LocationsViewModel
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    cameraPosition = .region(vm.mapRegion)
                }
                .onChange(of: RegionProxy(vm.mapRegion)) { _, _ in
                    withAnimation(.easeInOut) {
                        cameraPosition = .region(vm.mapRegion)
                    }
                }
            
            VStack (spacing: 0) {
                
                header
                    .padding()
                
                Spacer()
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
                    .foregroundStyle(.black)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .leading) {
                        Image(systemName: "arrow.down")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .padding()
                            .rotationEffect(Angle(degrees: vm.showLocationsList ? 180 : 0))
                    }
            }

            
            if vm.showLocationsList {
                LocationsListView()
            }
            
        }
        .background(.thickMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 15)
    }
}
