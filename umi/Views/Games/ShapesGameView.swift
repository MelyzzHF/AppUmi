//
//  ShapesGameView.swift
//  UmiApp
//
//  Juego de identificación de formas integrado
//

import SwiftUI

struct ShapesGameView: View {
    @Binding var isPresented: Bool
    
    @EnvironmentObject var colorManager: ColorManager
    @EnvironmentObject var speechManager: SpeechManager
    
    // Tupla que asocia el nombre de la forma con su icono de SFSymbols
    let allShapes: [(name: String, icon: String)] = [
        ("Círculo", "circle.fill"),
        ("Cuadrado", "square.fill"),
        ("Triángulo", "triangle.fill"),
        ("Estrella", "star.fill"),
        ("Rombo", "diamond.fill"),
        ("Corazón", "heart.fill")
    ]
    
    @State private var targetShape: (name: String, icon: String) = ("Círculo", "circle.fill")
    @State private var currentOptions: [(name: String, icon: String)] = []
    
    @State private var showFeedback = false
    @State private var isCorrect = false
    @State private var isProcessing = false
    
    var body: some View {
        ZStack {
            colorManager.palette.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                HStack {
                    CircularAccessibleButton(
                        icon: "xmark",
                        voiceLabel: "Cerrar juego de formas y volver al menú",
                        backgroundColor: colorManager.palette.buttonBackground,
                        size: 50
                    ) {
                        isPresented = false
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                UmiMascot(
                    mood: showFeedback ? (isCorrect ? .happy : .sad) : .happy,
                    message: showFeedback 
                        ? (isCorrect ? "¡Excelente! Ese es el \(targetShape.name)" : "Ese no es. ¡Intenta de nuevo!") 
                        : "Encuentra el \(targetShape.name)"
                )
                .frame(height: 140)
                
                Spacer()
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 30) {
                    ForEach(currentOptions, id: \.name) { shapeOption in
                        Button(action: {
                            checkAnswer(selected: shapeOption)
                        }) {
                            Image(systemName: shapeOption.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .frame(maxWidth: .infinity, minHeight: 140)
                                .background(colorManager.palette.cardBackground)
                                .foregroundColor(colorManager.palette.primary)
                                .cornerRadius(25)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(colorManager.palette.primary.opacity(0.3), lineWidth: 3)
                                )
                                .shadow(color: colorManager.palette.textColor.opacity(0.1), radius: 5, x: 0, y: 5)
                                .scaleEffect(isProcessing && isCorrect && shapeOption.name == targetShape.name ? 1.05 : 1.0)
                        }
                        .disabled(isProcessing)
                        .accessibilityLabel("Forma \(shapeOption.name)")
                        .accessibilityAddTraits(.isButton)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .onAppear {
            setupGame()
        }
    }
    
    private func setupGame() {
        let shuffledShapes = allShapes.shuffled()
        currentOptions = Array(shuffledShapes.prefix(4))
        targetShape = currentOptions.randomElement()!
        
        showFeedback = false
        isCorrect = false
        isProcessing = false
        
        speechManager.speak("Encuentra el \(targetShape.name)")
    }
    
    private func checkAnswer(selected: (name: String, icon: String)) {
        isProcessing = true
        showFeedback = true
        
        if selected.name == targetShape.name {
            isCorrect = true
            speechManager.speak("¡Muy bien! \(targetShape.name)")
            HapticManager.shared.successFeedback()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { setupGame() }
            }
        } else {
            isCorrect = false
            speechManager.speak("Oh oh, ese es el \(selected.name). Busca el \(targetShape.name).")
            HapticManager.shared.errorFeedback()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    showFeedback = false
                    isProcessing = false
                }
            }
        }
    }
}
