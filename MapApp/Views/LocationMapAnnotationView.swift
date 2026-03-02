import SwiftUI

/// Представление аннотации для карты.
/// Показывает круглую иконку карты с акцентным цветом и маленьким треугольником ниже (как указатель на точку на карте).
/// Используется для отображения местоположения на карте в виде пользовательской отметки.
struct LocationMapAnnotationView: View {
    var body: some View {
        VStack (spacing: 0) {
            Image(systemName: "map.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .font(.headline)
                .foregroundStyle(.white)
                .padding(6)
                .background(.accent)
                .cornerRadius(36)
            
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.accent)
                .frame(width: 10, height: 10)
                .rotationEffect(Angle(degrees: 180))
                .offset(y: -3)
                .padding(.bottom, 40)
            
        }
    }
}

#Preview {
    LocationMapAnnotationView()
}
