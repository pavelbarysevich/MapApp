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
    
    // Получаем экземпляр модели представления из окружения, чтобы иметь доступ к данным и логике экранa
    @Environment(LocationsViewModel.self) private var vm: LocationsViewModel
    
    // Локальное состояние положения камеры карты (центр/масштаб/угол),
    // которое связывается с Map в SwiftUI для контроля отображаемой области карты.
    // Изначально задано как .automatic — карта сама подберёт начальный регион.
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    // Максимальная ширина контента для iPad и больших экранов,
    // чтобы интерфейс не растягивался слишком широко и оставался удобочитаемым.
    let maxWidthForIpda: CGFloat = 700
    
    var body: some View {
        
        // Создаём локальную привязку к модели viewModel,
        // чтобы изменения в модели автоматически обновляли интерфейс.
        @Bindable var vm = vm
        
        // Основной контейнер ZStack, позволяющий наложить несколько слоёв друг на друга.
        ZStack {
            // Нижний слой — это карта с аннотациями и управлением камерой
            mapLayer
           
            // Верхний слой — вертикальный стек с заголовком вверху,
            // пустым пространством посередине и превью выбранной локации внизу
            VStack (spacing: 0) {
                
                // Заголовок с кнопкой раскрытия списка локаций и текущим названием
                header
                    // Отступы вокруг заголовка для эстетики
                    .padding()
                    // Ограничение максимальной ширины для больших экранов
                    .frame(maxWidth: maxWidthForIpda)
                
                // Заполнитель пространства между заголовком и превью,
                // чтобы превью всегда располагалось снизу
                Spacer()
                
                // Контейнер для показа превью выбранной локации,
                // который плавно меняется при переключении локаций
                locationsPreviewStack
            }
        }
        // Открытие полноэкранного листа с детальной информацией о локации,
        // когда в модели задан выбранный элемент для отображения
        .fullScreenCover(item: $vm.sheetLocation, onDismiss: nil) { location in
            LocationDetailView(location: location)
        }
    }
    
    // Слой карты с аннотациями для каждой локации
    private var mapLayer: some View {
        Map(position: $cameraPosition) {
            // Перебираем все локации из модели и создаём аннотации на карте
            ForEach(vm.locations) { location in
                // Каждая аннотация содержит имя и координаты локации
                Annotation(location.name, coordinate: location.coordinates) {
                    // Кастомное представление аннотации, визуально выделяемое
                    LocationMapAnnotationView()
                        // Масштаб анотации зависит от того, выбрана ли эта локация
                        // Выбранная увеличивается до полного размера, остальные уменьшаются
                        .scaleEffect(vm.mapLocation == location ? 1 : 0.7)
                        // Тень создаёт эффект объёма и выделенности на карте
                        .shadow(radius: 10)
                        // При тапе по аннотации вызываем функцию смены выбранной локации
                        .onTapGesture {
                            vm.showNextLocation(location: location)
                        }
                }
            }
        }
        // Карту растягиваем под весь экран
        .ignoresSafeArea()
        // При первом появлении экрана устанавливаем камеру карты на регион,
        // близкий к центру текущего региона модели, но с меньшим "зумом" (0.1 дельта)
        .onAppear {
            let center = vm.mapRegion.center
            let closeSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let closeRegion = MKCoordinateRegion(center: center, span: closeSpan)
            cameraPosition = .region(closeRegion)
        }
        // Отслеживаем изменения региона модели через специальный прокси (Equatable обёртка)
        // и плавно анимируем сдвиг камеры карты к новому региону с меньшим зумом
        .onChange(of: RegionProxy(vm.mapRegion)) { _, _ in
            withAnimation(.easeInOut) {
                let center = vm.mapRegion.center
                let closeSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let closeRegion = MKCoordinateRegion(center: center, span: closeSpan)
                cameraPosition = .region(closeRegion)
            }
        }
    }
    
    // Стек с превью текущей выбранной локации
    private var locationsPreviewStack: some View {
        ZStack {
            // Обходим все локации и показываем превью только для выбранной
            ForEach(vm.locations) { location in
                if vm.mapLocation == location {
                    LocationPreviewView(location: location)
                        // Тень добавляет глубину и отделяет превью визуально
                        .shadow(color: .black.opacity(0.3), radius: 20)
                        // Внутренние отступы для содержания превью
                        .padding()
                        // Ограничиваем максимальную ширину для больших экранов
                        .frame(maxWidth: maxWidthForIpda)
                        // Растягиваем превью по горизонтали внутри контейнера
                        .frame(maxWidth: .infinity)
                        // Плавная анимация появления и исчезновения превью:
                        // при появлении сдвигается справа, при скрытии уходит слева
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)))
                }
            }
        }
    }
}

// Превью для SwiftUI: создаём окружение с новой моделью `LocationsViewModel`,
// чтобы можно было видеть экран в Canvas или в симуляторе без запуска всего приложения
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
                // При нажатии вызывается функция из модели,
                // меняющая состояние флага показа списка (true/false)
                vm.toggleLocationsList()
            } label: {
                // Текст заголовка: имя текущей локации и города,
                // жирный крупный шрифт и чёрный цвет для акцента
                Text(vm.mapLocation.name + ", " + vm.mapLocation.cityName)
                    .font(.title2)
                    .fontWeight(.black)
                    // Используем пользовательский градиент из модели для цвета текста
                    .foregroundStyle(.wOne)
                    // Фиксированная высота, чтобы кнопка выглядела строго
                    .frame(height: 55)
                    // Растягиваем кнопку по ширине контейнера
                    .frame(maxWidth: .infinity)
                    // Наложение дополнительного слоя с иконкой стрелки слева
                    .overlay(alignment: .leading) {
                        // Иконка стрелки вниз, показывающая визуальное состояние раскрытия
                        Image(systemName: "arrow.down")
                            .font(.headline)
                            .foregroundStyle(.wOne)
                            .padding()
                            // Поворачиваем стрелку на 180 градусов, если список открыт,
                            // чтобы визуально показать направление раскрытия
                            .rotationEffect(Angle(degrees: vm.showLocationsList ? 180 : 0))
                    }
            }

            // При включённом флаге показываем список всех локаций под кнопкой
            if vm.showLocationsList {
                LocationsListView()
            }
            
        }
        // Используем светлый полупрозрачный фон, похожий на размытие (thinMaterial)
        .background(.thinMaterial)
        // Закругляем углы контейнера для современного визуального стиля
        .cornerRadius(20)
        // Добавляем тень для отделения заголовка от карты и нижнего содержимого
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 15)
    }
}


