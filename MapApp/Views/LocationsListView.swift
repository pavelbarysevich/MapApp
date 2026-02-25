// MARK: - LocationsListView
// Экран-список мест (локаций). Отображает список элементов из модели `LocationsViewModel`.
// По нажатию на строку списка выбирается соответствующая локация (через `vm.showNextLocation`).
// Вспомогательный метод `listRowView(location:)` отвечает за отрисовку одной строки списка.

import SwiftUI

// Основное представление списка локаций.
struct LocationsListView: View {
    
    // Получаем экземпляр модели представления из окружения SwiftUI (Environment).
    // `vm` предоставляет массив локаций и методы навигации/выбора.
    @Environment(LocationsViewModel.self) private var vm: LocationsViewModel
    
    // Основное содержимое вью: список (`List`) с кнопками-строками для каждой локации.
    var body: some View {
        // Стандартный SwiftUI-список. Для iOS отображает прокручиваемый список элементов.
        List {
            // Проходим по всем локациям из view model и создаём для каждой строку.
            ForEach(vm.locations) { location in
                // Каждая строка — это кнопка: при нажатии выбираем/показываем данную локацию.
                // В качестве содержимого кнопки используем кастомную вью `listRowView(location:)`.
                Button {
                    vm.showNextLocation(location: location) // Сообщаем view model, что пользователь выбрал эту локацию
                } label: {
                    listRowView(location: location)
                }
                .padding(.vertical, 4) // Небольшой вертикальный отступ между строками для визуального воздуха

            }
        }
        .listStyle(PlainListStyle()) // Плоский стиль списка без дополнительных разделителей/инсетных стилей
    }
}

// Превью для Xcode: позволяет увидеть список в Canvas без запуска приложения.
#Preview {
    LocationsListView()
        .environment(LocationsViewModel()) // Подставляем тестовый экземпляр view model в окружение превью
}

// Расширение с приватным методом для отрисовки одной строки списка.
extension LocationsListView {
    // Создаёт представление одной строки списка: миниатюра + название + город.
    private func listRowView(location: Location) -> some View {
        HStack {
            // Если у локации есть хотя бы одно изображение, показываем его как миниатюру слева.
            if let imageName = location.imageNames.first {
                Image(imageName) // Локальное изображение по имени из ассетов
                    .resizable() // Разрешаем изменять размер изображения
                    .scaledToFit() // Сохраняем пропорции, вписывая в отведённый размер
                    .frame(width: 45, height: 45) // Фиксированная миниатюра 45×45
                    .cornerRadius(10) // Скругляем углы миниатюры
            }
            
            // Вертикальный стек с названием локации (жирным) и названием города (подзаголовок).
            VStack(alignment: .leading){
                Text(location.name) // Основное название локации
                    .font(.headline) // Выделяем как заголовок
                Text(location.cityName) // Город, к которому относится локация
                    .font(.subheadline) // Менее акцентный подзаголовок
            }
            .frame(maxWidth: .infinity, alignment: .leading) // Растягиваем содержимое по ширине, выравнивание влево
        }
    }
}

