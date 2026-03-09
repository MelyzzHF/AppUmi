//
//  UmiMascot.swift
//  UmiApp
//
//  Mascota animada que guía y motiva a los niños
//

import SwiftUI

// MARK: - Estados de ánimo de Umi
enum UmiMood: String {
    case happy = "😊"
    case excited = "🎉"
    case thinking = "🤔"
    case celebrating = "🥳"
    case encouraging = "💪"
    case love = "🥰"
    case surprised = "😮"
    case proud = "🤩"
}

// MARK: - Mascota Umi
struct UmiMascot: View {
    let mood: UmiMood
    let message: String
    
    @EnvironmentObject var colorManager: ColorManager
    @State private var bounceOffset: CGFloat = 0
    @State private var wingRotation: Double = 0
    
    var body: some View {
        VStack(spacing: 12) {
            // Mariposa animada
            ZStack {
                // Alas izquierda
                Text("🦋")
                    .font(.system(size: 60))
                    .offset(y: bounceOffset)
                    .rotationEffect(.degrees(wingRotation), anchor: .center)
            }
            .accessibilityHidden(true)
            
            // Burbuja de diálogo
            HStack(spacing: 8) {
                Text(mood.rawValue)
                    .font(.system(size: 24))
                
                Text(message)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(colorManager.palette.textColor)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(colorManager.palette.cardBackground)
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Umi dice: \(message)")
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Animación de rebote
        withAnimation(
            Animation
                .easeInOut(duration: 1.0)
                .repeatForever(autoreverses: true)
        ) {
            bounceOffset = -10
        }
        
        // Animación de alas
        withAnimation(
            Animation
                .easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true)
        ) {
            wingRotation = 5
        }
    }
}

// MARK: - Umi con diferentes expresiones predefinidas
extension UmiMascot {
    static func welcome(colorManager: ColorManager) -> UmiMascot {
        UmiMascot(mood: .happy, message: "¡Hola! Soy Umi, tu amiga mariposa")
    }
    
    static func correct() -> UmiMascot {
        UmiMascot(mood: .celebrating, message: "¡Muy bien hecho!")
    }
    
    static func incorrect() -> UmiMascot {
        UmiMascot(mood: .encouraging, message: "¡Casi! Inténtalo de nuevo")
    }
    
    static func thinking() -> UmiMascot {
        UmiMascot(mood: .thinking, message: "¿Cuál es tu respuesta?")
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        UmiMascot(mood: .happy, message: "¡Bienvenido a Umi!")
        UmiMascot(mood: .celebrating, message: "¡Excelente trabajo!")
        UmiMascot(mood: .thinking, message: "¿Cuántas sílabas tiene?")
        UmiMascot(mood: .encouraging, message: "¡Tú puedes!")
    }
    .padding()
    .background(Color(hex: "FFF5F7"))
    .environmentObject(ColorManager())
}