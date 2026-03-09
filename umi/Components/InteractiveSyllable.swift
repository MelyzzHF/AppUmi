//
//  InteractiveSyllable.swift
//  UmiApp
//
//  Componente de sílaba interactiva con feedback de voz
//

import SwiftUI

// MARK: - Sílaba Interactiva
struct InteractiveSyllable: View {
    let syllable: String
    let index: Int
    let isHighlighted: Bool
    let onTap: (String, Int) -> Void
    
    @EnvironmentObject var colorManager: ColorManager
    @EnvironmentObject var speechManager: SpeechManager
    @State private var isAnimating = false
    
    var body: some View {
        Button(action: handleTap) {
            Text(syllable)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .frame(minWidth: 80)
                .background(
                    isHighlighted 
                        ? colorManager.palette.successColor 
                        : colorManager.palette.syllableColor
                )
                .foregroundColor(.white)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isHighlighted ? Color.white : Color.clear, lineWidth: 4)
                )
                .shadow(
                    color: colorManager.palette.syllableColor.opacity(0.4),
                    radius: 6,
                    x: 0,
                    y: 4
                )
                .scaleEffect(isAnimating ? 1.15 : (isHighlighted ? 1.1 : 1.0))
        }
        .contentShape(Rectangle())
        .accessibilityLabel("Sílaba \(syllable)")
        .accessibilityHint("Toca dos veces para escuchar")
        .accessibilityAddTraits(.isButton)
    }
    
    private func handleTap() {
        // Feedback háptico
        HapticManager.shared.syllablePattern()
        
        // Feedback de voz (más lento para sílabas)
        speechManager.speak(syllable, rate: 0.35)
        
        // Animación
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isAnimating = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isAnimating = false
            }
        }
        
        // Callback
        onTap(syllable, index)
    }
}

// MARK: - Fila de Sílabas
struct SyllableRow: View {
    let syllables: [String]
    let highlightedIndex: Int?
    let onSyllableTap: (String, Int) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(Array(syllables.enumerated()), id: \.offset) { index, syllable in
                InteractiveSyllable(
                    syllable: syllable,
                    index: index,
                    isHighlighted: highlightedIndex == index
                ) { syl, idx in
                    onSyllableTap(syl, idx)
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        Text("Sílabas de MARIPOSA")
            .font(.headline)
        
        SyllableRow(
            syllables: ["MA", "RI", "PO", "SA"],
            highlightedIndex: 1
        ) { syllable, index in
            print("Tocaste \(syllable) en posición \(index)")
        }
    }
    .padding()
    .environmentObject(ColorManager())
    .environmentObject(SpeechManager())
}