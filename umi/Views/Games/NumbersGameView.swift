//
//  NumbersGameView.swift
//  UmiApp
//
//  Juego de identificación de números integrado
//

import SwiftUI

struct NumbersGameView: View {
    @Binding var isPresented: Bool
    
    @EnvironmentObject var colorManager: ColorManager
    @EnvironmentObject var speechManager: SpeechManager
    
    @State private var targetNumber: Int = 1
    @State private var currentOptions: [Int] = []
    
    @State private var showFeedback = false
    @State private var isCorrect = false
    @State private var isProcessing = false
    
    var body: some View {
        ZStack {
            colorManager.palette.background.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Barra Superior
                HStack {
                    CircularAccessibleButton(
                        icon: "xmark",
                        voiceLabel: "Cerrar juego de números y volver al menú",
                        backgroundColor: colorManager.palette.buttonBackground,
                        size: 50
                    ) {
                        isPresented = false
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Mascota e Instrucción
                UmiMascot(
                    mood: showFeedback ? (isCorrect ? .happy : .sad) : .happy,
                    message: showFeedback 
                        ? (isCorrect ? "¡Excelente! Ese es el \(targetNumber)" : "Ese no es. ¡Intenta de nuevo!") 
                        : "Encuentra el número \(targetNumber)"
                )
                .frame(height: 140)
                
                Spacer()
                
                // Cuadrícula de Opciones
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(currentOptions, id: \.self) { numberOption in
                        Button(action: {
                            checkAnswer(selected: numberOption)
                        }) {
                            Text("\(numberOption)")
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity, minHeight: 130)
                                .background(colorManager.palette.cardBackground)
                                .foregroundColor(colorManager.palette.primary)
                                .cornerRadius(25)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(colorManager.palette.primary.opacity(0.3), lineWidth: 3)
                                )
                                .shadow(color: colorManager.palette.textColor.opacity(0.1), radius: 5, x: 0, y: 5)
                                .scaleEffect(isProcessing && isCorrect && numberOption == targetNumber ? 1.05 : 1.0)
                        }
                        .disabled(isProcessing)
                        .accessibilityLabel("Número \(numberOption)")
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
        var optionsSet = Set<Int>()
        targetNumber = Int.random(in: 1...10)
        optionsSet.insert(targetNumber)
        
        while optionsSet.count < 4 {
            optionsSet.insert(Int.random(in: 1...10))
        }
        
        currentOptions = Array(optionsSet).shuffled()
        showFeedback = false
        isCorrect = false
        isProcessing = false
        
        speechManager.speak("Encuentra el número \(targetNumber)")
    }
    
    private func checkAnswer(selected: Int) {
        isProcessing = true
        showFeedback = true
        
        if selected == targetNumber {
            isCorrect = true
            speechManager.speak("¡Muy bien! \(targetNumber)")
            HapticManager.shared.successFeedback()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { setupGame() }
            }
        } else {
            isCorrect = false
            speechManager.speak("Oh oh, ese es el \(selected). Busca el \(targetNumber).")
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
