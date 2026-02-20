import SwiftUI

extension Color {
    // MARK: - Background Colors
    static let appBackground = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    
    // MARK: - Fill Colors
    static let primaryFill = Color(UIColor.secondarySystemFill) // Para fondos de celdas
    static let secondaryFill = Color(UIColor.tertiarySystemFill) // Para fondos secundarios
    
    // MARK: - Text Colors
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let tertiaryText = Color(UIColor.tertiaryLabel)
    
    // MARK: - Gray Scale
    static let lightGray = Color.gray.opacity(0.6) // Para divisores
    static let mediumGray = Color.gray
    static let darkGray = Color(UIColor.darkGray)
    
    // MARK: - Accent Colors
    static let appBlue = Color.blue // Para botones de acción y plus
    static let appPink = Color.pink // Para favoritos y acentos
    static let appRed = Color.red // Para eliminar o errores
    static let appGreen = Color.green // Para éxito
    
    // MARK: - Spark Stars
    static let starFilled = Color.blue // Estrella llena
    static let starEmpty = Color.gray.opacity(0.3) // Estrella vacía
    
    // MARK: - Navigation
    static let navBarText = Color.primary
    static let navBarBackground = Color(UIColor.systemBackground)
    
    // MARK: - Search Bar
    static let searchBarBackground = Color(UIColor.secondarySystemFill)
    static let searchBarText = Color.primary
    static let searchBarIcon = Color.gray
    static let searchBarClearButton = Color.gray
}

// MARK: - ViewModifiers para reutilizar estilos
extension View {
    func cardStyle(cornerRadius: CGFloat = 20) -> some View {
        self
            .background(Color.primaryFill)
            .cornerRadius(cornerRadius)
    }
    
    func searchBarStyle() -> some View {
        self
            .padding(10)
            .background(Color.searchBarBackground)
            .cornerRadius(20)
    }
    
    func dividerStyle() -> some View {
        Divider()
            .background(Color.lightGray)
            .padding(.leading, 12)
            .padding(.trailing, 12)
    }
}

// MARK: - Constantes de diseño
struct DesignConstants {
    // MARK: - Corner Radius
    static let smallCornerRadius: CGFloat = 8
    static let mediumCornerRadius: CGFloat = 12
    static let largeCornerRadius: CGFloat = 20
    
    // MARK: - Padding
    static let smallPadding: CGFloat = 4
    static let mediumPadding: CGFloat = 8
    static let largePadding: CGFloat = 12
    static let extraLargePadding: CGFloat = 16
    
    // MARK: - Spacing
    static let smallSpacing: CGFloat = 4
    static let mediumSpacing: CGFloat = 8
    static let largeSpacing: CGFloat = 12
    
    // MARK: - Opacity
    static let dividerOpacity: Double = 0.6
    static let disabledOpacity: Double = 0.3
}
