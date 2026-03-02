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

// `LocationDetailView` отображает детальную информацию о локации:
// фотографии, описание, ссылку, карту и кнопку закрытия.
struct LocationDetailView: View {
    
    // Ссылка на модель данных локаций
    @Environment(LocationsViewModel.self) private var vm: LocationsViewModel
    // Определяет размер экрана (компактный/регулярный)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    // Управление положением камеры карты
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    // Максимальная ширина контента для iPad
    private let maxWidthForiPad: CGFloat = 700
    
    let location: Location
    
    // Определяет, является ли устройство компактным (iPhone)
    private var isCompact: Bool { horizontalSizeClass == .compact }
    
    // Основной UI-код экрана
    var body: some View {
        // Адаптивная верстка с учетом размеров экрана
        GeometryReader { proxy in
            let contentWidth = isCompact ? proxy.size.width : min(proxy.size.width, maxWidthForiPad)
            let imageHeight: CGFloat = isCompact ? 400 : min(600, proxy.size.height * 0.45)
            
            // Основной скроллируемый контент
            ScrollView {
                Group {
                    // Основной контент (фото, описание, карта)
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
            // Кнопка закрытия/назад
            .overlay(alignment: .topLeading) {
                backButton
            }
        }
    }
    
}

// Превью для SwiftUI Canvas/Previews
#Preview {
    LocationDetailView(location: LocationsDataService.locations.first!)
        .environment(LocationsViewModel())
}

extension LocationDetailView {
    // Основной вертикальный стек с контентом
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
    
    // TabView с фото
    private func imageSection(width: CGFloat, height: CGFloat) -> some View {
        TabView {
            // Перебираем все имена изображений локации
            ForEach(location.imageNames, id: \.self) {
                Image($0)
                    .resizable()
                    .scaledToFill()
                    // Устанавливаем размер каждой фотографии
                    .frame(width: width, height: height)
                    .clipped()
            }
        }
        .frame(width: width, height: height)
        .tabViewStyle(.page)
        .cornerRadius(30)
    }
    
    // Секция с названием и городом
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
    
    // Блок описания и ссылки на Wikipedia
    private var descriptionSection: some View {
        VStack (alignment: .leading, spacing: 16) {
            Text(location.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Если есть валидная ссылка, показываем её
            if let url = URL(string: location.link) {
                Link("Подробно в Wikipedia", destination: url)
                    .font(.headline)
                    .tint(.blue)
            }
        }
    }
    
    // Карта с одной аннотацией и автоматической установкой региона
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
            // Устанавливаем регион с близким масштабом
            let closeSpan = MKCoordinateSpan(latitudeDelta: 0.004, longitudeDelta: 0.004)
            let region = MKCoordinateRegion(
                center: location.coordinates,
                span: closeSpan
            )
            // Обновляем позицию камеры карты
            cameraPosition = .region(region)
        }
    }
    
    // Кнопка закрытия этого экрана
    private var backButton: some View {
        Button {
            // Сбрасываем выбранную локацию в модели, закрывая экран
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

