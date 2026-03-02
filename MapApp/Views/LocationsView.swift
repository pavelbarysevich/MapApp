/**
 LocationsView — это основной экран приложения для отображения списка локаций на карте и просмотра их информации.
 
 Основные возможности:
 - Показывает интерактивную карту с аннотациями для всех локаций.
 - Позволяет выбирать локацию, просматривать детали и переключаться между ними.
 - Содержит кнопку-«шапку» для отображения списка всех локаций.
 - Отображает превью выбранной локации и открывает подробную информацию по клику.
*/

import SwiftUI
// MapKit используется для работы с картой и координатами
import MapKit

// Основное представление экрана с картой и интерфейсом выбора локаций
struct LocationsView: View {
    
    
    @Environment(LocationsViewModel.self) private var vm: LocationsViewModel
    // Локальное состояние положения камеры карты (центр/масштаб/угол)
    // Используется для программного управления картой через SwiftUI Map
    @State private var cameraPosition: MapCameraPosition = .automatic
    let maxWidthForIpda: CGFloat = 700
    
    var body: some View {
        
        @Bindable var vm = vm
        
        ZStack {
            mapLayer
           
            VStack (spacing: 0) {
                
                // Заголовок с кнопкой раскрытия списка локаций и текущим названием
                header
                    .padding()
                    .frame(maxWidth: maxWidthForIpda)
                
                Spacer()
                
                locationsPreviewStack
            }
        }
        .fullScreenCover(item: $vm.sheetLocation, onDismiss: nil) { location in
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
                        .frame(maxWidth: maxWidthForIpda)
                        .frame(maxWidth: .infinity)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)))
                }
            }
        }
    }
}

// Превью для SwiftUI: создаём окружение с новой моделью `LocationsViewModel`
#Preview {
    LocationsView()
        .environment(LocationsViewModel())
}

// Вспомогательная оболочка над `MKCoordinateRegion`, чтобы сделать его `Equatable`.
// `MKCoordinateRegion` сам по себе не Equatable, поэтому SwiftUI `onChange(of:)` не сможет корректно отслеживать изменения.
// Сохраняем ключевые поля (центр и спан) в простые типы, чтобы сравнение работало детерминированно.
private struct RegionProxy: Equatable {
    // Нормализованные значения региона для сравнения
    let latitude: Double
    let longitude: Double
    let latDelta: Double
    let lonDelta: Double

    // Инициализация из `MKCoordinateRegion`: извлекаем центр и дельты спана
    init(_ region: MKCoordinateRegion) {
        latitude = region.center.latitude
        longitude = region.center.longitude
        latDelta = region.span.latitudeDelta
        lonDelta = region.span.longitudeDelta
    }
}

// Вынос разметки заголовка (`header`) в расширение для удобства чтения
extension LocationsView {
    private var header: some View {
        // Заголовок содержит кнопку-"шторку" и, при необходимости, список локаций
        VStack {
            
            // Кнопка переключает видимость списка локаций
            Button {
                vm.toggleLocationsList()
            } label: {
                // Текст заголовка: имя текущей локации и города. Жирный крупный шрифт, чёрный цвет
                Text(vm.mapLocation.name + ", " + vm.mapLocation.cityName)
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundStyle(.wOne)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .leading) {
                        // Иконка стрелки слева. Поворачивается на 180° при раскрытом списке
                        Image(systemName: "arrow.down")
                            .font(.headline)
                            .foregroundStyle(.wOne)
                            .padding()
                            .rotationEffect(Angle(degrees: vm.showLocationsList ? 180 : 0))
                    }
            }

            // При включённом флаге показываем список всех локаций под кнопкой
            if vm.showLocationsList {
                LocationsListView()
            }
            
        }
        .background(.thinMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 15)
    }
}

