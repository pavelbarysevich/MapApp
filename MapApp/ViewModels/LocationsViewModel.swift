/*
 LocationsViewModel — это наблюдаемый класс, управляющий состоянием и логикой для отображения и переключения местоположений на карте с помощью MapKit и SwiftUI. 

 Основные функции класса:
 - Хранит список всех доступных местоположений
 - Отслеживает текущее выбранное место и регион карты
 - Позволяет переключаться между местоположениями, обновляя карту с анимацией
 - Управляет состояниями отображения списка мест и детальной информации
*/

import SwiftUI
import Observation
import MapKit

/// @Observable делает экземпляры класса наблюдаемыми для SwiftUI.
/// Любое изменение публичных свойств приведёт к автоматическому обновлению соответствующих View.
/// Это современная альтернатива @StateObject/@ObservedObject для моделей состояния.

/// Модель представления (ViewModel) для экрана с картой.
/// - Управляет текущей локацией и регионом карты.
/// - Предоставляет список всех доступных локаций.
/// - Отвечает за показ/скрытие списка и переход к следующей локации.
@Observable class LocationsViewModel {
    
    /// Все загруженные локации, доступные пользователю.
    /// Источник данных — `LocationsDataService.locations`.
    /// Предполагается, что массив не пуст (как минимум одна демо-локация).
    var locations: [Location]
    
    /// Текущее выбранное местоположение.
    /// Изменение этого свойства:
    /// - Триггерит `didSet`, который вызывает `updateMapRedion(location:)`.
    /// - Синхронизирует центр и масштаб карты с координатами выбранной локации.
    var mapLocation: Location {
        didSet {
            updateMapRedion(location: mapLocation) // Синхронизируем регион карты с новой локацией
        }
    }
    
    /// Текущий видимый регион карты (центр и масштаб).
    /// Используется MapKit для отображения области вокруг выбранной локации.
    var mapRegion: MKCoordinateRegion = MKCoordinateRegion()
    
    /// Масштаб (span) карты.
    /// Меньшие значения `latitudeDelta`/`longitudeDelta` — более сильное приближение.
    /// 0.1 — умеренное приближение, подходящее для городского масштаба; при необходимости подберите под задачу.
    let mapSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    
    /// Управляет показом списка локаций (например, выпадающей панели).
    /// true — список виден, false — скрыт.
    var showLocationsList: Bool = false
    
    var sheetLocation: Location? = nil
    
    init() {
        let locations = LocationsDataService.locations
        self.locations = locations
        self.mapLocation = locations.first! // предполагается, что массив не пуст (демо-данные)
        self.updateMapRedion(location: locations.first!)
    }
    
    /// Обновляет регион карты под переданную локацию.
    /// - Parameter location: локация, чьи координаты становятся центром карты.
    /// Обновление обёрнуто в `withAnimation(.easeInOut)` для плавного перемещения/масштабирования.
    private func updateMapRedion(location: Location) {
        withAnimation(.easeInOut) {
            mapRegion = MKCoordinateRegion( // Формируем новый регион на основе координат и текущего span
                center: location.coordinates,
                span: mapSpan)
        }
    }
    
    /// Переключает видимость списка локаций с плавной анимацией.
    /// Удобно для раскрытия/сворачивания панели со списком.
    func toggleLocationsList() {
        withAnimation(.easeInOut) {
            showLocationsList = !showLocationsList // Инвертируем текущее состояние
        }
    }
    
    /// Делает переданную локацию текущей и скрывает список.
    /// - Parameter location: локация, которую требуется отобразить (центрировать карту).
    func showNextLocation(location: Location) {
        withAnimation(.easeInOut) {
            mapLocation = location // Выбираем новую локацию; didSet обновит регион карты
            showLocationsList = false
        }
    }
    
    /// Обработка нажатия на кнопку "Далее".
    /// Логика:
    /// - Находим индекс текущей локации.
    /// - Пытаемся перейти к следующей.
    /// - Если достигнут конец массива — возвращаемся к первой (циклическая навигация).
    /// В маловероятном случае несоответствия состояния выводим диагностическое сообщение.
    func nextButtonPressed() {
        guard let currentIndex = locations.firstIndex(where: { $0 == mapLocation }) else {
            print("Could not find current index in locations array! Should never happen.")
            return
        }
        
        let nextIndex = currentIndex + 1 // Индекс следующего элемента
        guard locations.indices.contains(nextIndex) else { // Если вышли за границы — берём первую локацию
            guard let firstLocation = locations.first else {return }
            showNextLocation(location: firstLocation)
            return
        }
        
        let nextLocation = locations[nextIndex] // Валидная следующая локация
        showNextLocation(location: nextLocation)
    }
}

