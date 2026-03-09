//
//  WordCard.swift
//  UmiApp
//
//  Tarjeta que muestra la palabra actual con botones de audio
//

import SwiftUI

// MARK: - Tarjeta de Palabra
struct WordCard: View {
    let word: Word
    let onSpeak: () -> Void
    let onSpeakSyllables: () -> Void
    
    @EnvironmentObject var colorManager: ColorManager
    @EnvironmentObject var speechManager: SpeechManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Palabra principal
            Text(word.text)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(colorManager.palette.textColor)
                .tracking(8)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .accessibilityLabel("Palabra: \(word.text)")
                .onTapGesture {
                    onSpeak()
                }
            
            // Botones de audio
            HStack(spacing: 15) {
                AccessibleButton(
                    title: "Escuchar",
                    icon: "🔊",
                    voiceLabel: "Escuchar la palabra",
                    size: .small,
                    backgroundColor: colorManager.palette.buttonBackground
                ) {
                    onSpeak()
                }
                
                AccessibleButton(
                    title: "Sílabas",
                    icon: "🎵",
                    voiceLabel: "Escuchar las sílabas una por una",
                    size: .small,
                    backgroundColor: colorManager.palette.syllableColor
                ) {
                    onSpeakSyllables()
                }
            }
        }
        .padding(30)
        .background(colorManager.palette.cardBackground)
        .cornerRadius(30)
        .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 8)
    }
}

// MARK: - Tarjeta de Letra Grande
struct LetterCard: View {
    let letter: Character
    let onSpeak: () -> Void
    
    @EnvironmentObject var colorManager: ColorManager
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(String(letter))
                .font(.system(size: 120, weight: .bold, design: .rounded))
                .foregroundColor(colorManager.palette.textColor)
                .scaleEffect(isAnimating ? 1.05 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                    value: isAnimating
                )
            
            AccessibleButton(
                title: "Escuchar",
                icon: "🔊",
                voiceLabel: "Escuchar la letra",
                size: .medium,
                backgroundColor: colorManager.palette.buttonBackground
            ) {
                onSpeak()
            }
        }
        .padding(40)
        .frame(width: 220, height: 260)
        .background(colorManager.palette.cardBackground)
        .cornerRadius(40)
        .overlay(
            RoundedRectangle(cornerRadius: 40)
                .stroke(colorManager.palette.primary, lineWidth: 6)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Letra a clasificar: \(String(letter))")
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Información de Sílabas
struct SyllableInfo: View {
    let count: Int
    
    @EnvironmentObject var colorManager: ColorManager
    @EnvironmentObject var speechManager: SpeechManager
    
    var body: some View {
        HStack(spacing: 8) {
            Text("Esta palabra tiene")
                .font(.system(size: 16, weight: .medium, design: .rounded))
            
            Text("\(count)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(colorManager.palette.syllableColor)
            
            Text(count == 1 ? "sílaba" : "sílabas")
                .font(.system(size: 16, weight: .medium, design: .rounded))
        }
        .foregroundColor(colorManager.palette.textColor)
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(colorManager.palette.cardBackground)
        .cornerRadius(20)
        .accessibilityLabel("Esta palabra tiene \(count) \(count == 1 ? "sílaba" : "sílabas")")
        .onTapGesture {
            speechManager.speak("Esta palabra tiene \(count) \(count == 1 ? "sílaba" : "sílabas")")
            HapticManager.shared.selectionFeedback()
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 30) {
        WordCard(
            word: Word(text: "MARIPOSA", syllables: ["MA", "RI", "PO", "SA"]),
            onSpeak: { },
            onSpeakSyllables: { }
        )
        
        LetterCard(letter: "A") { }
        
        SyllableInfo(count: 4)
    }
    .padding()
    .background(Color(hex: "FFF5F7"))
    .environmentObject(ColorManager())
    .environmentObject(SpeechManager())
}