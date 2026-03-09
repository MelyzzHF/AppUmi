//
//  ColorSettingsView.swift
//  UmiApp
//
//  Vista de configuración de paletas de colores para daltonismo
//  Permite cambiar entre diferentes modos de color accesibles
//

import SwiftUI

// MARK: - Vista de Configuración de Colores
struct ColorSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var colorManager: ColorManager
    @EnvironmentObject var speechManager: SpeechManager
    
    var body: some View {
        NavigationView {
            ZStack {
                // Fondo
                colorManager.palette.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Encabezado
                        headerSection
                        
                        // Opciones de paleta
                        paletteOptions
                        
                        // Botón de cerrar
                        closeButton
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            speechManager.speak("Configuración de colores. Selecciona el modo que mejor se adapte a tu tipo de visión.")
        }
    }
    
    // MARK: - Encabezado
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("🎨")
                .font(.system(size: 50))
            
            Text("Colores Accesibles")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(colorManager.palette.textColor)
            
            Text("Selecciona el modo que mejor se adapte a tu tipo de visión")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(colorManager.palette.textColor.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Configuración de colores accesibles. Selecciona el modo que mejor se adapte a tu tipo de visión.")
    }
    
    // MARK: - Opciones de Paleta
    private var paletteOptions: some View {
        VStack(spacing: 12) {
            ForEach(ColorPaletteType.allCases) { paletteType in
                PaletteOptionButton(
                    paletteType: paletteType,
                    isSelected: colorManager.currentPaletteType == paletteType
                ) {
                    selectPalette(paletteType)
                }
            }
        }
    }
    
    // MARK: - Botón de Cerrar
    private var closeButton: some View {
        AccessibleButton(
            title: "Listo",
            icon: "✓",
            voiceLabel: "Cerrar configuración",
            size: .large,
            backgroundColor: colorManager.palette.successColor
        ) {
            dismiss()
        }
        .padding(.top, 10)
    }
    
    // MARK: - Seleccionar Paleta
    private func selectPalette(_ type: ColorPaletteType) {
        colorManager.changePalette(to: type)
        speechManager.speak("Modo \(type.rawValue) seleccionado")
        HapticManager.shared.successFeedback()
    }
}

// MARK: - Botón de Opción de Paleta
struct PaletteOptionButton: View {
    let paletteType: ColorPaletteType
    let isSelected: Bool
    let action: () -> Void
    
    @EnvironmentObject var colorManager: ColorManager
    
    private var palette: ColorPalette {
        ColorPalette.palette(for: paletteType)
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Muestra de colores
                HStack(spacing: 5) {
                    Circle()
                        .fill(palette.vowelColor)
                        .frame(width: 30, height: 30)
                    
                    Circle()
                        .fill(palette.consonantColor)
                        .frame(width: 30, height: 30)
                    
                    Circle()
                        .fill(palette.syllableColor)
                        .frame(width: 30, height: 30)
                }
                
                // Información
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(paletteType.icon)
                            .font(.system(size: 18))
                        
                        Text(paletteType.rawValue)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                    }
                    
                    Text(paletteType.description)
                        .font(.system(size: 12, weight: .medium))
                        .opacity(0.7)
                }
                .foregroundColor(palette.textColor)
                
                Spacer()
                
                // Indicador de selección
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(palette.successColor)
                }
            }
            .padding(20)
            .background(
                paletteType == .highContrast 
                    ? Color(hex: "1A1A1A") 
                    : Color(hex: "F8F8F8")
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ? palette.primary : Color.clear,
                        lineWidth: 4
                    )
            )
        }
        .accessibilityLabel("\(paletteType.rawValue). \(paletteType.description)")
        .accessibilityHint(isSelected ? "Seleccionado" : "Toca dos veces para seleccionar")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

// MARK: - Preview
#Preview {
    ColorSettingsView()
        .environmentObject(ColorManager())
        .environmentObject(SpeechManager())
}