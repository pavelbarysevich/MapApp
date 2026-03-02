// MARK: -
// Структура Location описывает объект локации для отображения на карте.
// Включает название, город, координаты, описание, имена изображений и ссылку.
// Соответствует протоколам Identifiable (идентификатор — комбинация названия и города)
// и Equatable (две локации считаются равными, если их id совпадают).

import SwiftUI
import MapKit

struct Location: Identifiable, Equatable {
    let name: String
    let cityName: String
    let coordinates: CLLocationCoordinate2D
    let description: String
    let imageNames: [String]
    let link: String
    
    var id: String {
        name + cityName
    }
    
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == rhs.id
    }
}

