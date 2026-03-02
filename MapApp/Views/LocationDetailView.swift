/**
 `LocationDetailView` — экран подробной информации о выбранной локации.
 
 Показывает:
 - Слайдер с фото
 - Название и описание
 - Ссылку на Wikipedia
 - Карту с отмеченной локацией
 - Кнопку закрытия ("назад")

 Поддерживает адаптивную верстку для iPhone и iPad.
 */
import SwiftUI
import MapKit

struct LocationDetailView: View {
    
    @Environment(LocationsViewModel.self) private var vm: LocationsViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    private let maxWidthForiPad: CGFloat = 700
    
    let location: Location
    
    private var isCompact: Bool { horizontalSizeClass == .compact }
    
    var body: some View {
        GeometryReader { proxy in
            let contentWidth = isCompact ? proxy.size.width : min(proxy.size.width, maxWidthForiPad)
            let imageHeight: CGFloat = isCompact ? 400 : min(600, proxy.size.height * 0.45)
            
            ScrollView {
                Group {
                    if isCompact {
                        mainContent(width: contentWidth, height: imageHeight)
                    } else {
                        HStack(spacing: 0) {
                            Spacer(minLength: 0)
                            mainContent(width: contentWidth, height: imageHeight)
                                .frame(maxWidth: maxWidthForiPad)
                            Spacer(minLength: 0)
                        }
                    }
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
    @ViewBuilder
    private func mainContent(width: CGFloat, height: CGFloat) -> some View {
        VStack {
            imageSection(width: width, height: height)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
            
            VStack(alignment: .leading, spacing: 16) {
                titleSection
                Divider()
                descriptionSection
                Divider()
                mapLayer
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
    }
    
    private func imageSection(width: CGFloat, height: CGFloat) -> some View {
        TabView {
            ForEach(location.imageNames, id: \.self) {
                Image($0)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()
            }
        }
        .frame(width: width, height: height)
        .tabViewStyle(.page)
        .cornerRadius(30)
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

