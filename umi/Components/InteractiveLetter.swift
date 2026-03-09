//
//  InteractiveLetter.swift
//  UmiApp
//
//  Componente de letra interactiva con feedback accesible
//  Diferencia visualmente vocales y consonantes
//

import SwiftUI

// MARK: - Letra Interactiva
struct InteractiveLetter: View {
    let letter: Character
    let isSelected: Bool
    let showType: Bool
    let onTap: (Character, Bool) -> Void
    
    @EnvironmentObject var colorManager: ColorManager
    @EnvironmentObject var speechManager: SpeechManager
    @State private var isAnimating = false
    
    private var isVowel: Bool {
        Alphabet.isVowel(letter)
    }
    
    private var letterType: String {
        isVowel ? "vocal" : "consonante"
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return colorManager.palette.successColor
        }
        return isVowel ? colorManager.palette.vowelColor : colorManager.palette.consonantColor
    }
    
    var body: some View {
        Button(action: handleTap) {
            VStack(spacing: 4) {
                Text(String(letter))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.5)
                
                if showType {
                    HStack(spacing: 2) {
                        Text(isVowel ? "🔴" : "🔵")
                            .font(.system(size: 10))
                        Text(isVowel ? "Vocal" : "Cons.")
                            .font(.system(size: 10, weight: .medium))
                    }
                    .opacity(0.9)
                }
            }
            .frame(width: 80, height: 80)
            .background(backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 4)
            )
            .shadow(color: backgroundColor.opacity(0.4), radius: 6, x: 0, y: 4)
            .scaleEffect(isAnimating ? 1.1 : 1.0)
        }
        // Zona de toque amplia
        .contentShape(Rectangle())
        // Accesibilidad
        .accessibilityLabel("Letra \(String(letter)), es una \(letterType)")
        .accessibilityHint(isSelected ? "Seleccionada" : "Toca dos veces para seleccionar")
        .accessibilityAddTraits(.isButton)
    }
    
    private func handleTap() {
        // Feedback háptico según tipo de letra
        if isVowel {
            HapticManager.shared.vowelPattern()
        } else {
            HapticManager.shared.consonantPattern()
        }
        
        // Feedback de voz
        speechManager.speak("\(letter), es una \(letterType)")
        
        // Animación
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isAnimating = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isAnimating = false
            }
        }
        
        // Callback
        onTap(letter, isVowel)
    }
}

// MARK: - Grid de Letras
struct LetterGrid: View {
    let word: String
    let selectedIndices: Set<Int>
    let showTypes: Bool
    let onLetterTap: (Int, Character, Bool) -> Void
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 80), spacing: 12)
        ], spacing: 12) {
            ForEach(Array(word.enumerated()), id: \.offset) { index, letter in
                InteractiveLetter(
                    letter: letter,
                    isSelected: selectedIndices.contains(index),
                    showType: showTypes
                ) { char, isVowel in
                    onLetterTap(index, char, isVowel)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        Text("Toca las letras:")
            .font(.headline)
        
        LetterGrid(
            word: "CASA",
            selectedIndices: [0, 2],
            showTypes: true
        ) { index, letter, isVowel in
            print("Tocaste \(letter) en posición \(index), es vocal: \(isVowel)")
        }
    }
    .padding()
    .environmentObject(ColorManager())
    .environmentObject(SpeechManager())
}