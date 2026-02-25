// LocationPreviewView.swift
// Представление превью локации: показывает изображение, название и город,
// а также кнопки для просмотра подробностей и перехода к следующей локации.
// Все ключевые части разметки подробно прокомментированы ниже.

import SwiftUI

/// Основной компонент превью одной локации.
/// - Использует Environment для доступа к `LocationsViewModel`.
/// - Принимает `location` — модель данных конкретной локации для отображения.
struct LocationPreviewView: View {
    
    /// Внедрение зависимостей через Environment: доступ к общему `LocationsViewModel`.
    @Environment(LocationsViewModel.self) private var vm: LocationsViewModel
    
    /// Конкретная локация, данные которой отображаются в превью (имя, город, изображения и т.д.).
    let location: Location
    
    /// Основная разметка:
    /// HStack с двумя вертикальными колонками:
    /// 1) Левая колонка: картинка локации + заголовок (название и город).
    /// 2) Правая колонка: две кнопки (узнать больше, далее).
    /// Вся карточка имеет скругления и полупрозрачный фон (.ultraThinMaterial) со смещением.
    var body: some View {
        
        HStack(alignment: .bottom, spacing: 0) {
            // Левая колонка: изображение + текстовые заголовки
            VStack (alignment: .leading, spacing: 16) {
                // Секция с изображением локации (если доступно)
                imageSection
                // Секция с названием локации и названием города
                titleSection
            }
            
            // Правая колонка: кнопки действий
            VStack (spacing: 8){
                // Кнопка: открыть подробную информацию о локации (логика будет добавлена в обработчик)
                learnMoreButton
                // Кнопка: перейти к следующей локации (использует метод во view model)
                nextButton
            }
        } // конец HStack с двумя колонками
        // Оформление карточки: внутренние отступы, материал, скругления
        .padding(20)
        .background(
            // Полупрозрачный фон с эффектом материала, смещён вниз на 65 для визуального слоя под контентом
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .offset(y: 65)
        )
        .cornerRadius(20)
        
    }
}

extension LocationPreviewView {
    /// Секция изображения: показывает первое изображение из массива `location.imageNames` (если есть).
    /// Картинка заполняет 100x100, обрезается по углам, на белом фоне с внешним паддингом.
    private var imageSection: some View {
        ZStack {
            // Пытаемся получить первое имя изображения из массива. Если его нет — секция будет пустой.
            if let imageNames = location.imageNames.first {
                Image(imageNames) // Загружаем изображение по имени из ассетов
                    .resizable()
                    .scaledToFill() // Заполняем доступное пространство, сохраняя пропорции (могут быть обрезки)
                    .frame(width: 100, height: 100) // Явно задаём размер превью
                    .cornerRadius(10) // Скругляем углы изображения
                
            }
        }
        .padding(6) // Внутренний отступ вокруг изображения
        .background(.white) // Подложка белого цвета под изображением
        .cornerRadius(10) // Скругление фона вокруг изображения
    }
    
    /// Секция заголовка: название локации (жирный шрифт) и название города (подзаголовок).
    /// Контент выравнивается влево и растягивается по ширине.
    private var titleSection: some View {
        VStack (alignment: .leading, spacing: 4) {
            // Название локации крупным шрифтом
            Text(location.name)
                .font(.title2) // Предустановленный размер шрифта для заголовка
                .fontWeight(.bold) // Жирное начертание для акцента
            
            // Название города более мелким шрифтом
            Text(location.cityName)
                .font(.subheadline) // Размер шрифта подзаголовка
        }
        .frame(maxWidth: .infinity, alignment: .leading) // Растягиваем по ширине и выравниваем влево
    }
    
    /// Кнопка "Узнать больше": визуально выделена (.borderedProminent).
    /// На данный момент действие пустое — сюда можно добавить навигацию к деталям.
    private var learnMoreButton: some View {
        Button {
            // TODO: реализовать переход/открытие подробной информации о локации
        } label: {
            Text("Узнать больше") // Текст на кнопке
                .font(.headline)
                .frame(width: 135, height: 35) // Фиксированный размер кнопки для согласованного вида
        }
        .buttonStyle(.borderedProminent) // Выделенный стиль кнопки
    }
    
    /// Кнопка "Далее": вызывает `vm.nextButtonPressed()` для переключения на следующую локацию.
    /// Имеет вторичный стиль (.bordered).
    private var nextButton: some View {
        Button {
            vm.nextButtonPressed() // Делегируем действие во view model
        } label: {
            Text("Далее") // Текст на кнопке
                .font(.headline)
                .frame(width: 135, height: 35) // Фиксированный размер кнопки
        }
        .buttonStyle(.bordered) // Вторичный стиль кнопки
    }
}

/// Превью для Canvas/Xcode Previews: подставляет первую локацию из сервиса данных
/// и окружение с `LocationsViewModel` для демонстрации работы в изоляции.
#Preview {
    ZStack {
        // Фоновый цвет для визуального контраста в превью
        Color.yellow.ignoresSafeArea()
        LocationPreviewView(location: LocationsDataService.locations.first!) // Демонстрация с первой локацией (force unwrap допустим в превью)
            .padding() // Внешние отступы вокруг превью
    }
    .environment(LocationsViewModel()) // Предоставляем экземпляр view model через Environment для превью
}

