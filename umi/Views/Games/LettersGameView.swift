//
//  LettersGameView.swift
//  UmiApp
//
//  Juego de identificación de letras integrado
//

import SwiftUI

struct LettersGameView: View {
    @Binding var isPresented: Bool
    
    @EnvironmentObject var colorManager: ColorManager
    @EnvironmentObject var speechManager: SpeechManager
    
    let allLetters: [String] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ").map { String($0) }
    
    @State private var targetLetter: String = "A"
    @State private var currentOptions: [String] = []
    
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
                        voiceLabel: "Cerrar juego de letras y volver al menú",
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
                        ? (isCorrect ? "¡Excelente! Esa es la letra \(targetLetter)" : "Esa no es. ¡Intenta de nuevo!") 
                        : "Encuentra la letra \(targetLetter)"
                )
                .frame(height: 140)
                
                Spacer()
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(currentOptions, id: \.self) { letterOption in
                        Button(action: {
                            checkAnswer(selected: letterOption)
                        }) {
                            Text(letterOption)
                                .font(.system(size: 60, weight: .heavy, design: .rounded))
                                .frame(maxWidth: .infinity, minHeight: 130)
                                .background(colorManager.palette.cardBackground)
                                .foregroundColor(colorManager.palette.accent)
                                .cornerRadius(25)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(colorManager.palette.accent.opacity(0.3), lineWidth: 3)
                                )
                                .shadow(color: colorManager.palette.textColor.opacity(0.1), radius: 5, x: 0, y: 5)
                                .scaleEffect(isProcessing && isCorrect && letterOption == targetLetter ? 1.05 : 1.0)
                        }
                        .disabled(isProcessing)
                        .accessibilityLabel("Letra \(letterOption)")
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
        var optionsSet = Set<String>()
        targetLetter = allLetters.randomElement()!
        optionsSet.insert(targetLetter)
        
        while optionsSet.count < 4 {
            optionsSet.insert(allLetters.randomElement()!)
        }
        
        currentOptions = Array(optionsSet).shuffled()
        showFeedback = false
        isCorrect = false
        isProcessing = false
        
        speechManager.speak("Encuentra la letra \(targetLetter)")
    }
    
    private func checkAnswer(selected: String) {
        isProcessing = true
        showFeedback = true
        
        if selected == targetLetter {
            isCorrect = true
            speechManager.speak("¡Muy bien! Letra \(targetLetter)")
            HapticManager.shared.successFeedback()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation { setupGame() }
            }
        } else {
            isCorrect = false
            speechManager.speak("Oh oh, esa es la \(selected). Busca la \(targetLetter).")
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
