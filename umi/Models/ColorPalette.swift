//
//  ColorPalette.swift
//  UmiApp
//
//  Paletas de colores accesibles para diferentes tipos de daltonismo
//

import SwiftUI

// MARK: - Tipos de Paleta de Colores
enum ColorPaletteType: String, CaseIterable, Identifiable {
    case normal = "Normal"
    case protanopia = "Protanopía"
    case deuteranopia = "Deuteranopía"
    case tritanopia = "Tritanopía"
    case highContrast = "Alto Contraste"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .normal:
            return "Colores estándar"
        case .protanopia:
            return "Optimizado para dificultad con rojos"
        case .deuteranopia:
            return "Optimizado para dificultad con verdes"
        case .tritanopia:
            return "Optimizado para dificultad con azules"
        case .highContrast:
            return "Máximo contraste para baja visión"
        }
    }
    
    var icon: String {
        switch self {
        case .normal: return "🌈"
        case .protanopia: return "🔵"
        case .deuteranopia: return "🟡"
        case .tritanopia: return "🔴"
        case .highContrast: return "⚫"
        }
    }
}

// MARK: - Estructura de Paleta de Colores
struct ColorPalette {
    let primary: Color
    let secondary: Color
    let accent: Color
    let background: Color
    let vowelColor: Color
    let consonantColor: Color
    let syllableColor: Color
    let textColor: Color
    let buttonBackground: Color
    let successColor: Color
    let cardBackground: Color
    let errorColor: Color
    
    // MARK: - Paletas Predefinidas
    static let normal = ColorPalette(
        primary: Color(hex: "FF6B9D"),
        secondary: Color(hex: "4ECDC4"),
        accent: Color(hex: "FFE66D"),
        background: Color(hex: "FFF5F7"),
        vowelColor: Color(hex: "FF6B9D"),
        consonantColor: Color(hex: "4ECDC4"),
        syllableColor: Color(hex: "9B59B6"),
        textColor: Color(hex: "2C3E50"),
        buttonBackground: Color(hex: "FF6B9D"),
        successColor: Color(hex: "2ECC71"),
        cardBackground: Color.white,
        errorColor: Color(hex: "E74C3C")
    )
    
    static let protanopia = ColorPalette(
        primary: Color(hex: "0077BB"),
        secondary: Color(hex: "EE7733"),
        accent: Color(hex: "FFDD00"),
        background: Color(hex: "F5F9FF"),
        vowelColor: Color(hex: "0077BB"),
        consonantColor: Color(hex: "EE7733"),
        syllableColor: Color(hex: "CC3311"),
        textColor: Color(hex: "1A1A2E"),
        buttonBackground: Color(hex: "0077BB"),
        successColor: Color(hex: "009988"),
        cardBackground: Color.white,
        errorColor: Color(hex: "CC3311")
    )
    
    static let deuteranopia = ColorPalette(
        primary: Color(hex: "332288"),
        secondary: Color(hex: "DDCC77"),
        accent: Color(hex: "88CCEE"),
        background: Color(hex: "F8F6FF"),
        vowelColor: Color(hex: "332288"),
        consonantColor: Color(hex: "DDCC77"),
        syllableColor: Color(hex: "AA4499"),
        textColor: Color(hex: "1A1A2E"),
        buttonBackground: Color(hex: "332288"),
        successColor: Color(hex: "44AA99"),
        cardBackground: Color.white,
        errorColor: Color(hex: "882255")
    )
    
    static let tritanopia = ColorPalette(
        primary: Color(hex: "EE3377"),
        secondary: Color(hex: "33BBEE"),
        accent: Color(hex: "009988"),
        background: Color(hex: "FFF5F8"),
        vowelColor: Color(hex: "EE3377"),
        consonantColor: Color(hex: "33BBEE"),
        syllableColor: Color(hex: "EE7733"),
        textColor: Color(hex: "1A1A2E"),
        buttonBackground: Color(hex: "EE3377"),
        successColor: Color(hex: "009988"),
        cardBackground: Color.white,
        errorColor: Color(hex: "CC3311")
    )
    
    static let highContrast = ColorPalette(
        primary: Color.white,
        secondary: Color(hex: "FFD700"),
        accent: Color(hex: "00FF00"),
        background: Color.black,
        vowelColor: Color(hex: "FFD700"),
        consonantColor: Color(hex: "00FFFF"),
        syllableColor: Color(hex: "FF69B4"),
        textColor: Color.white,
        buttonBackground: Color(hex: "333333"),
        successColor: Color(hex: "00FF00"),
        cardBackground: Color(hex: "1A1A1A"),
        errorColor: Color(hex: "FF0000")
    )
    
    // MARK: - Obtener paleta por tipo
    static func palette(for type: ColorPaletteType) -> ColorPalette {
        switch type {
        case .normal: return .normal
        case .protanopia: return .protanopia
        case .deuteranopia: return .deuteranopia
        case .tritanopia: return .tritanopia
        case .highContrast: return .highContrast
        }
    }
}

// MARK: - Extensión para crear colores desde hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}