//
//  ColorsGameView.swift
//  UmiApp
//
//  Juego de identificación de colores integrado
//

import SwiftUI

struct ColorsGameView: View {
    // Para cerrar la vista y volver al menú
    @Binding var isPresented: Bool
    
    // Gestores globales de AppUmi
    @EnvironmentObject var colorManager: ColorManager
    @EnvironmentObject var speechManager: SpeechManager
    
    // MARK: - Estado del Juego
    // Lista de colores disponibles con sus nombres en español
    let allColors: [(Color, String)] = [
        (.red, "Rojo"),
        (.blue, "Azul"),
        (.green, "Verde"),
        (.yellow, "Amarillo"),
        (.orange, "Naranja"),
        (.purple, "Morado"),
        (.pink, "Rosa"),
        (.cyan, "Celeste")
    ]
    
    @State private var targetColor: (Color, String) = (.red, "Rojo")
    @State private var currentOptions: [(Color, String)] = []
    
    // Estados para la retroalimentación visual y de Umi
    @State private var showFeedback = false
    @State private var isCorrect = false
    @State private var isProcessing = false // Evita toques múltiples mientras se anima
    
    var body: some View {
        ZStack {
            // Fondo accesible gestionado por ColorManager
            colorManager.palette.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // MARK: - Barra Superior
                HStack {
                    // Botón accesible de AppUmi para volver al menú
                    CircularAccessibleButton(
                        icon: "xmark",
                        voiceLabel: "Cerrar juego de colores y volver al menú",
                        backgroundColor: colorManager.palette.buttonBackground,
                        size: 50
                    ) {
                        isPresented = false
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // MARK: - Mascota e Instrucción
                UmiMascot(
                    mood: showFeedback ? (isCorrect ? .happy : .sad) : .happy,
                    message: showFeedback 
                        ? (isCorrect ? "¡Excelente! Ese es el color \(targetColor.1)" : "Ese no es. ¡Intenta de nuevo!") 
                        : "Toca el círculo de color \(targetColor.1)"
                )
                .frame(height: 140)
                
                // Palabra a buscar destacada
                Text(targetColor.1.uppercased())
                    .font(.system(size: 48, weight: .heavy, design: .rounded))
                    .foregroundColor(colorManager.palette.primary)
                    .accessibilityHidden(true) // Oculto para VoiceOver porque Umi ya lo dice
                
                Spacer()
                
                // MARK: - Cuadrícula de Opciones
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 30) {
                    ForEach(currentOptions, id: \.1) { colorOption in
                        Button(action: {
                            checkAnswer(selected: colorOption)
                        }) {
                            Circle()
                                .fill(colorOption.0)
                                .frame(width: 130, height: 130)
                                // Borde para asegurar contraste en fondos del mismo color
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.5), lineWidth: 4)
                                )
                                .shadow(color: colorOption.0.opacity(0.4), radius: 8, x: 0, y: 5)
                                // Animación de pulsación al tocar (opcional, dependiente del estado)
                                .scaleEffect(isProcessing && isCorrect && colorOption.1 == targetColor.1 ? 1.1 : 1.0)
                        }
                        .disabled(isProcessing) // Deshabilita mientras da el resultado
                        .accessibilityLabel("Color \(colorOption.1)")
                        .accessibilityAddTraits(.isButton)
                    }
                }
                .padding(.horizontal, 30)
                
                Spacer()
            }
        }
        .onAppear {
            setupGame()
        }
    }
    
    // MARK: - Lógica del Juego
    
    private func setupGame() {
        // Seleccionamos 4 colores aleatorios
        let shuffledColors = allColors.shuffled()
        currentOptions = Array(shuffledColors.prefix(4))
        
        // Elegimos la respuesta correcta de entre las opciones mostradas
        targetColor = currentOptions.randomElement()!
        
        // Reseteamos estados
        showFeedback = false
        isCorrect = false
        isProcessing = false
        
        // Reproducir instrucción inicial
        speechManager.speak("Encuentra el color \(targetColor.1)")
    }
    
    private func checkAnswer(selected: (Color, String)) {
        isProcessing = true
        showFeedback = true
        
        if selected.1 == targetColor.1 {
            // Respuesta Correcta
            isCorrect = true
            speechManager.speak("¡Muy bien! \(targetColor.1)")
            HapticManager.shared.successFeedback() // Si tienes este método en tu HapticManager
            
            // Esperar 2 segundos y cargar el siguiente nivel
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation {
                    setupGame()
                }
            }
        } else {
            // Respuesta Incorrecta
            isCorrect = false
            speechManager.speak("Oh oh, ese es \(selected.1). Busca el \(targetColor.1).")
            HapticManager.shared.errorFeedback() // Si tienes este método
            
            // Quitar el mensaje de error después de 2.5 segundos
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showFeedback = false
                    isProcessing = false
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    ColorsGameView(isPresented: .constant(true))
        .environmentObject(ColorManager())
        .environmentObject(SpeechManager())
}
