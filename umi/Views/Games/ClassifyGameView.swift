//
//  ClassifyGameView.swift
//  UmiApp
//
//  Juego rápido para clasificar letras como vocales o consonantes
//

import SwiftUI

// MARK: - Vista del Juego de Clasificación
struct ClassifyGameView: View {
    @Binding var isPresented: Bool
    
    @EnvironmentObject var colorManager: ColorManager
    @EnvironmentObject var speechManager: SpeechManager
    
    @State private var currentLetter: Character = "A"
    @State private var score: Int = 0
    @State private var streak: Int = 0
    @State private var feedback: FeedbackState = .none
    @State private var isAnimatingLetter: Bool = false
    
    enum FeedbackState {
        case none
        case correct
        case incorrect
    }
    
    var body: some View {
        ZStack {
            // Fondo
            colorManager.palette.background
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                headerSection
                
                Spacer()
                
                // Mascota
                mascotSection
                
                // Tarjeta de letra
                LetterCard(letter: currentLetter) {
                    speechManager.speak("La letra es: \(String(currentLetter))")
                    HapticManager.shared.selectionFeedback()
                }
                
                // Recordatorio de vocales
                vowelReminder
                
                Spacer()
                
                // Botones de clasificación
                classificationButtons
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            loadNewLetter()
            speechManager.speak("Juego de clasificar. Decide si cada letra es vocal o consonante.")
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            AccessibleButton(
                title: "Volver",
                icon: "←",
                voiceLabel: "Volver al menú principal",
                size: .small,
                backgroundColor: colorManager.palette.buttonBackground
            ) {
                isPresented = false
            }
            
            Spacer()
            
            Text("🎯 Clasificar")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(colorManager.palette.primary)
            
            Spacer()
            
            ScoreDisplay(score: score, streak: streak)
        }
    }
    
    // MARK: - Mascota
    private var mascotSection: some View {
        UmiMascot(
            mood: moodForFeedback,
            message: messageForFeedback
        )
    }
    
    private var moodForFeedback: UmiMood {
        switch feedback {
        case .none: return .thinking
        case .correct: return .celebrating
        case .incorrect: return .encouraging
        }
    }
    
    private var messageForFeedback: String {
        switch feedback {
        case .none: return "¿Es vocal o consonante?"
        case .correct: return "¡Correcto! 🎉"
        case .incorrect: return "¡Inténtalo de nuevo! 💪"
        }
    }
    
    // MARK: - Recordatorio de Vocales
    private var vowelReminder: some View {
        HStack(spacing: 8) {
            Text("💡")
                .font(.system(size: 18))
            
            Text("Recuerda:")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
            
            Text("Las vocales son")
                .font(.system(size: 14, weight: .medium, design: .rounded))
            
            Text("A E I O U")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(colorManager.palette.vowelColor)
        }
        .foregroundColor(colorManager.palette.textColor)
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(colorManager.palette.cardBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .accessibilityLabel("Recuerda: Las vocales son A, E, I, O, U")
        .onTapGesture {
            speechManager.speak("Recuerda: Las vocales son A, E, I, O, U")
            HapticManager.shared.selectionFeedback()
        }
    }
    
    // MARK: - Botones de Clasificación
    private var classificationButtons: some View {
        HStack(spacing: 30) {
            // Botón VOCAL
            ClassificationButton(
                title: "VOCAL",
                icon: "🔴",
                color: colorManager.palette.vowelColor,
                voiceLabel: "Botón vocal. Presiona si la letra es A, E, I, O o U"
            ) {
                classify(as: .vowel)
            }
            
            // Botón CONSONANTE
            ClassificationButton(
                title: "CONSONANTE",
                icon: "🔵",
                color: colorManager.palette.consonantColor,
                voiceLabel: "Botón consonante. Presiona si la letra NO es vocal"
            ) {
                classify(as: .consonant)
            }
        }
    }
    
    // MARK: - Clasificar Letra
    private enum Classification {
        case vowel
        case consonant
    }
    
    private func classify(as classification: Classification) {
        let isVowel = Alphabet.isVowel(currentLetter)
        let isCorrect = (classification == .vowel && isVowel) || (classification == .consonant && !isVowel)
        
        if isCorrect {
            // Respuesta correcta
            score += 10 + (streak * 2)
            streak += 1
            feedback = .correct
            
            let type = isVowel ? "vocal" : "consonante"
            speechManager.speak("¡Muy bien! \(currentLetter) es una \(type)")
            HapticManager.shared.celebrationPattern()
            
            // Cargar nueva letra después de un momento
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                loadNewLetter()
            }
        } else {
            // Respuesta incorrecta
            streak = 0
            feedback = .incorrect
            
            let correctType = isVowel ? "vocal" : "consonante"
            speechManager.speak("No, \(currentLetter) es una \(correctType). ¡Inténtalo de nuevo!")
            HapticManager.shared.errorFeedback()
        }
    }
    
    // MARK: - Cargar Nueva Letra
    private func loadNewLetter() {
        currentLetter = Alphabet.randomLetter()
        feedback = .none
        speechManager.speak("Clasifica la letra: \(String(currentLetter))")
    }
}

// MARK: - Botón de Clasificación
struct ClassificationButton: View {
    let title: String
    let icon: String
    let color: Color
    let voiceLabel: String
    let action: () -> Void
    
    @EnvironmentObject var speechManager: SpeechManager
    @State private var isPressed: Bool = false
    
    var body: some View {
        Button(action: {
            HapticManager.shared.mediumImpact()
            action()
        }) {
            VStack(spacing: 10) {
                Text(icon)
                    .font(.system(size: 50))
                
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(width: 140, height: 140)
            .background(color)
            .cornerRadius(30)
            .shadow(color: color.opacity(0.4), radius: 10, x: 0, y: 5)
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .contentShape(Rectangle())
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
        .onLongPressGesture(minimumDuration: 0.5) {
            speechManager.speak(voiceLabel)
        }
    }
}

// MARK: - Preview
#Preview {
    ClassifyGameView(isPresented: .constant(true))
        .environmentObject(ColorManager())
        .environmentObject(SpeechManager())
}