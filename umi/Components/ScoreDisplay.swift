//
//  ScoreDisplay.swift
//  UmiApp
//
//  Componente para mostrar puntuación y racha
//

import SwiftUI

// MARK: - Display de Puntuación
struct ScoreDisplay: View {
    let score: Int
    let streak: Int?
    
    @EnvironmentObject var colorManager: ColorManager
    @EnvironmentObject var speechManager: SpeechManager
    
    var body: some View {
        HStack(spacing: 10) {
            // Racha (si existe)
            if let streak = streak, streak > 0 {
                ScoreBadge(
                    icon: "🔥",
                    value: streak,
                    label: "Racha de \(streak) aciertos"
                )
            }
            
            // Puntuación
            ScoreBadge(
                icon: "⭐",
                value: score,
                label: "Puntuación: \(score) puntos"
            )
        }
    }
}

// MARK: - Badge Individual
struct ScoreBadge: View {
    let icon: String
    let value: Int
    let label: String
    
    @EnvironmentObject var colorManager: ColorManager
    @EnvironmentObject var speechManager: SpeechManager
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 6) {
            Text(icon)
                .font(.system(size: 18))
            
            Text("\(value)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(colorManager.palette.textColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(colorManager.palette.accent)
        .cornerRadius(15)
        .scaleEffect(isAnimating ? 1.1 : 1.0)
        .accessibilityLabel(label)
        .accessibilityAddTraits(.updatesFrequently)
        .onTapGesture {
            speechManager.speak(label)
            HapticManager.shared.selectionFeedback()
        }
        .onChange(of: value) { _, _ in
            // Animar cuando cambia el valor
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                isAnimating = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    isAnimating = false
                }
            }
        }
    }
}

// MARK: - Selector de Dificultad
struct DifficultySelector: View {
    @Binding var selectedDifficulty: Difficulty
    
    @EnvironmentObject var colorManager: ColorManager
    @EnvironmentObject var speechManager: SpeechManager
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(Difficulty.allCases) { difficulty in
                DifficultyButton(
                    difficulty: difficulty,
                    isSelected: selectedDifficulty == difficulty
                ) {
                    selectedDifficulty = difficulty
                    speechManager.speak(difficulty.voiceLabel)
                    HapticManager.shared.selectionFeedback()
                }
            }
        }
    }
}

// MARK: - Botón de Dificultad
struct DifficultyButton: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let action: () -> Void
    
    @EnvironmentObject var colorManager: ColorManager
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(difficulty.icon)
                    .font(.system(size: 16))
                
                Text(difficulty.rawValue)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                isSelected 
                    ? colorManager.palette.successColor 
                    : colorManager.palette.buttonBackground.opacity(0.7)
            )
            .foregroundColor(.white)
            .cornerRadius(15)
        }
        .accessibilityLabel("\(difficulty.rawValue), \(difficulty.voiceLabel)")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        ScoreDisplay(score: 150, streak: 5)
        
        DifficultySelector(selectedDifficulty: .constant(.medium))
    }
    .padding()
    .background(Color(hex: "FFF5F7"))
    .environmentObject(ColorManager())
    .environmentObject(SpeechManager())
}
