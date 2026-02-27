import SwiftUI
import MapKit

struct LocationDetailView: View {
    
    @Environment(LocationsViewModel.self) private var vm: LocationsViewModel
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    let location: Location
    
    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack {
                    imageSection(width: proxy.size.width)
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    VStack (alignment: .leading, spacing: 16) {
                        titleSection
                        Divider()
                        descriptionSection
                        Divider()
                        mapLayer
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
                .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea()
            .background(.ultraThinMaterial)
            .overlay(alignment: .topLeading) {
                backButton
            }
        }
    }
    
}

#Preview {
    LocationDetailView(location: LocationsDataService.locations.first!)
        .environment(LocationsViewModel())
}

extension LocationDetailView {
    private func imageSection(width: CGFloat) -> some View {
        TabView {
            ForEach(location.imageNames, id: \.self) {
                Image($0)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: 500)
                    .clipped()
            }
        }
        .frame(height: 500)
        .tabViewStyle(PageTabViewStyle())
    }
    
    private var titleSection: some View {
        VStack (alignment: .leading, spacing: 8) {
            Text(location.name)
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text(location.cityName)
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
    
    private var descriptionSection: some View {
        VStack (alignment: .leading, spacing: 16) {
            Text(location.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if let url = URL(string: location.link) {
                Link("Подробно в Wikipedia", destination: url)
                    .font(.headline)
                    .tint(.blue)
            }
        }
    }
    
    private var mapLayer: some View {
        Map(position: $cameraPosition) {
            // Одна аннотация для текущей локации
            Annotation(location.name, coordinate: location.coordinates) {
                LocationMapAnnotationView()
                    .shadow(radius: 10)
            }
        }
        .allowsHitTesting(false)
        .aspectRatio(1, contentMode: .fit)
        .cornerRadius(30)
        .onAppear {
            // Устанавливаем регион покрупнее/помельче по желанию
            let closeSpan = MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
            let region = MKCoordinateRegion(
                center: location.coordinates,
                span: closeSpan
            )
            cameraPosition = .region(region)
        }
    }

//        Map(position: $cameraPosition) {
//            ForEach(vm.locations) { location in
//                Annotation(location.name, coordinate: location.coordinates) {
//                    LocationMapAnnotationView()
//                        .scaleEffect(vm.mapLocation == location ? 1 : 0.7)
//                        .shadow(radius: 10)
//                        .onTapGesture {
//                            vm.showNextLocation(location: location)
//                        }
//                }
//            }
//        }
//        .ignoresSafeArea()
//        .onAppear {
//            let center = vm.mapRegion.center
//            let closeSpan = MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
//            let closeRegion = MKCoordinateRegion(center: center, span: closeSpan)
//            cameraPosition = .region(closeRegion)
//        }
//        .onChange(of: RegionProxy(vm.mapRegion)) { _, _ in
//            withAnimation(.easeInOut) {
//                let center = vm.mapRegion.center
//                let closeSpan = MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
//                let closeRegion = MKCoordinateRegion(center: center, span: closeSpan)
//                cameraPosition = .region(closeRegion)
//            }
//        }
    
    private var backButton: some View {
        Button {
            vm.sheetLocation = nil
        } label: {
            Image(systemName: "xmark")
                .font(.headline)
                .padding(16)
                .foregroundStyle(.black)
                .background(.thinMaterial)
                .cornerRadius(30)
                .shadow(radius: 4)
                .padding()
            
        }

    }
}

