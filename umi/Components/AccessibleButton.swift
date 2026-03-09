//
//  AccessibleButton.swift
//  UmiApp
//
//  Botón accesible con soporte para VoiceOver, Dynamic Type y feedback háptico
//  Zonas de toque amplias para facilitar la interacción motriz
//

import SwiftUI

// MARK: - Tamaños de Botón
enum ButtonSize {
    case small
    case medium
    case large
    
    var height: CGFloat {
        switch self {
        case .small: return 50
        case .medium: return 70
        case .large: return 90
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 20
        case .large: return 24
        }
    }
    
    var padding: EdgeInsets {
        switch self {
        case .small: return EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
        case .medium: return EdgeInsets(top: 18, leading: 32, bottom: 18, trailing: 32)
        case .large: return EdgeInsets(top: 24, leading: 48, bottom: 24, trailing: 48)
        }
    }
}

// MARK: - Botón Accesible
struct AccessibleButton: View {
    let title: String
    let icon: String?
    let voiceLabel: String
    let size: ButtonSize
    let backgroundColor: Color
    let action: () -> Void
    
    @EnvironmentObject var speechManager: SpeechManager
    @State private var isPressed = false
    
    init(
        title: String,
        icon: String? = nil,
        voiceLabel: String,
        size: ButtonSize = .medium,
        backgroundColor: Color,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.voiceLabel = voiceLabel
        self.size = size
        self.backgroundColor = backgroundColor
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            // Feedback háptico
            HapticManager.shared.mediumImpact()
            
            // Feedback de voz
            speechManager.speak(voiceLabel)
            
            // Ejecutar acción
            action()
        }) {
            HStack(spacing: 10) {
                if let icon = icon {
                    Text(icon)
                        .font(.system(size: size.fontSize + 4))
                }
                
                Text(title)
                    .font(.system(size: size.fontSize, weight: .bold, design: .rounded))
                    // Soporte para Dynamic Type
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .padding(size.padding)
            .frame(minHeight: size.height)
            .frame(maxWidth: size == .large ? .infinity : nil)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(20)
            .shadow(color: backgroundColor.opacity(0.4), radius: 8, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        // Ampliar zona de toque para accesibilidad motriz
        .contentShape(Rectangle())
        // Configuración de accesibilidad para VoiceOver
        .accessibilityLabel(voiceLabel)
        .accessibilityHint("Toca dos veces para activar")
        .accessibilityAddTraits(.isButton)
        // Animación al presionar
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

// MARK: - Modificador para detectar eventos de presión
struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        onPress()
                    }
                    .onEnded { _ in
                        onRelease()
                    }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressActions(onPress: onPress, onRelease: onRelease))
    }
}

// MARK: - Botón Circular Accesible
struct CircularAccessibleButton: View {
    let icon: String
    let voiceLabel: String
    let backgroundColor: Color
    let size: CGFloat
    let action: () -> Void
    
    @EnvironmentObject var speechManager: SpeechManager
    @State private var isPressed = false
    
    init(
        icon: String,
        voiceLabel: String,
        backgroundColor: Color,
        size: CGFloat = 60,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.voiceLabel = voiceLabel
        self.backgroundColor = backgroundColor
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            HapticManager.shared.selectionFeedback()
            speechManager.speak(voiceLabel)
            action()
        }) {
            Text(icon)
                .font(.system(size: size * 0.4))
                .frame(width: size, height: size)
                .background(backgroundColor)
                .foregroundColor(.white)
                .clipShape(Circle())
                .shadow(color: backgroundColor.opacity(0.4), radius: 6, x: 0, y: 3)
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .contentShape(Circle())
        .accessibilityLabel(voiceLabel)
        .accessibilityAddTraits(.isButton)
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        AccessibleButton(
            title: "Jugar",
            icon: "🎮",
            voiceLabel: "Comenzar a jugar",
            size: .large,
            backgroundColor: .pink
        ) {
            print("Botón presionado")
        }
        
        AccessibleButton(
            title: "Volver",
            icon: "←",
            voiceLabel: "Volver al menú",
            size: .small,
            backgroundColor: .blue
        ) {
            print("Volver")
        }
        
        CircularAccessibleButton(
            icon: "🎨",
            voiceLabel: "Configuración de colores",
            backgroundColor: .purple
        ) {
            print("Configuración")
        }
    }
    .padding()
    .environmentObject(SpeechManager())
}