//
//  ColorManager.swift
//  UmiApp
//
//  Gestor de paletas de colores para accesibilidad
//

import SwiftUI

// MARK: - Color Manager
class ColorManager: ObservableObject {
    @Published var currentPaletteType: ColorPaletteType = .normal {
        didSet {
            // Guardar preferencia del usuario
            UserDefaults.standard.set(currentPaletteType.rawValue, forKey: "selectedColorPalette")
        }
    }
    
    var palette: ColorPalette {
        ColorPalette.palette(for: currentPaletteType)
    }
    
    init() {
        // Cargar preferencia guardada
        if let saved = UserDefaults.standard.string(forKey: "selectedColorPalette"),
           let type = ColorPaletteType(rawValue: saved) {
            self.currentPaletteType = type
        }
    }
    
    func changePalette(to type: ColorPaletteType) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentPaletteType = type
        }
    }
}