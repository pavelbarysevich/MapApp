// LocationsView.swift
// Экран с картой и списком локаций. Отвечает за:
// - Отображение карты с текущей областью (регионом)
// - Синхронизацию положения камеры карты с моделью `LocationsViewModel`
// - Заголовок с кнопкой для показа/скрытия списка локаций
// - Превью выбранной локации поверх карты

import SwiftUI
// MapKit используется для работы с картой и координатами
import MapKit

// Основное представление экрана с картой и интерфейсом выбора локаций
struct LocationsView: View {
    
    // Модель состояния экрана, предоставляемая через Environment
    // Хранит список локаций, выбранную локацию, текущий регион карты и флаги UI
    @Environment(LocationsViewModel.self) private var vm: LocationsViewModel
    // Локальное состояние положения камеры карты (центр/масштаб/угол)
    // Используется для программного управления картой через SwiftUI Map
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        // ZStack: карта на заднем плане, поверх неё — заголовок и превью локации
        ZStack {
            // Компонент карты, связанный с состоянием `cameraPosition`.
            // Любое изменение `cameraPosition` программно обновит видимую область карты.
            // Карту растягиваем на весь экран и отключаем безопасные области, чтобы она была под всем контентом.
            Map(position: $cameraPosition)
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // При появлении экрана устанавливаем начальный регион карты из модели `vm.mapRegion`
                .onAppear {
                    cameraPosition = .region(vm.mapRegion)
                }
                // Следим за изменениями региона карты из модели.
                // Оборачиваем `MKCoordinateRegion` во вспомогательную структуру `RegionProxy`,
                // чтобы обеспечить корректное сравнение (Equatable) и триггерить обновления при изменениях центра/спана.
                // При изменении плавно анимируем перемещение камеры к новому региону.
                .onChange(of: RegionProxy(vm.mapRegion)) { _, _ in
                    withAnimation(.easeInOut) {
                        cameraPosition = .region(vm.mapRegion)
                    }
                }
            
            // Вертикальный стек: сверху — заголовок с кнопкой и (опционально) списком,
            // снизу — превью текущей выбранной локации поверх карты
            VStack (spacing: 0) {
                
                // Заголовок с кнопкой раскрытия списка локаций и текущим названием
                header
                    .padding()
                
                Spacer()
                
                // Контейнер для показа превью выбранной локации. Показываем только одну — текущую `vm.mapLocation`.
                ZStack {
                    ForEach(vm.locations) { location in
                        // Отрисовываем превью только для текущей выбранной локации.
                        // Используем асимметричный переход при смене локаций (справа налево).
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
                    .foregroundStyle(.black)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .leading) {
                        // Иконка стрелки слева. Поворачивается на 180° при раскрытом списке
                        Image(systemName: "arrow.down")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .padding()
                            .rotationEffect(Angle(degrees: vm.showLocationsList ? 180 : 0))
                    }
            }

            // При включённом флаге показываем список всех локаций под кнопкой
            if vm.showLocationsList {
                LocationsListView()
            }
            
        }
        // Стиль фона и оформления заголовка: материал, скругления и тень
        .background(.thickMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 15)
    }
}
