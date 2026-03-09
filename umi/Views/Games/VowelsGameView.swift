//
//  VowelsGameView.swift
//  UmiApp
//
//  Juego para identificar vocales en palabras
//

import SwiftUI

// MARK: - Vista del Juego de Vocales
struct VowelsGameView: View {
    @Binding var isPresented: Bool
    
    @EnvironmentObject var colorManager: ColorManager
    @EnvironmentObject var speechManager: SpeechManager
    
    @State private var currentWord: Word?
    @State private var selectedIndices: Set<Int> = []
    @State private var showResult: Bool = false
    @State private var isCorrect: Bool = false
    @State private var score: Int = 0
    
    var body: some View {
        ZStack {
            // Fondo
            colorManager.palette.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Instrucciones
                instructionsCard
                
                // Mascota
                mascotSection
                
                Spacer()
                
                // Contenido del juego
                if let word = currentWord {
                    gameContent(word: word)
                }
                
                Spacer()
                
                // Botones de acción
                actionButtons
            }
            .padding()
        }
        .onAppear {
            loadNewWord()
            speechManager.speak("Juego de vocales. Encuentra las letras A, E, I, O, U en cada palabra.")
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
            
            Text("🔴 Vocales")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(colorManager.palette.vowelColor)
            
            Spacer()
            
            ScoreDisplay(score: score, streak: nil)
        }
    }
    
    // MARK: - Tarjeta de Instrucciones
    private var instructionsCard: some View {
        HStack(spacing: 8) {
            Text("Las vocales son:")
                .font(.system(size: 16, weight: .medium, design: .rounded))
            
            Text("A - E - I - O - U")
                .font(.system(size: 18, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(colorManager.palette.vowelColor)
        .cornerRadius(20)
        .accessibilityLabel("Las vocales son: A, E, I, O, U")
        .onTapGesture {
            speechManager.speak("Las vocales son: A, E, I, O, U")
            HapticManager.shared.selectionFeedback()
        }
    }
    
    // MARK: - Mascota
    private var mascotSection: some View {
        UmiMascot(
            mood: showResult ? (isCorrect ? .celebrating : .encouraging) : .thinking,
            message: showResult
                ? (isCorrect ? "¡Muy bien hecho!" : "¡Sigue intentando!")
                : "¡Toca las letras que son vocales!"
        )
    }
    
    // MARK: - Contenido del Juego
    private func gameContent(word: Word) -> some View {
        VStack(spacing: 24) {
            // Palabra mostrada
            Text(word.text)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(colorManager.palette.textColor)
                .tracking(4)
                .accessibilityLabel("Palabra: \(word.text)")
                .onTapGesture {
                    speechManager.speak("La palabra es: \(word.text)")
                    HapticManager.shared.selectionFeedback()
                }
            
            // Grid de letras
            LetterGrid(
                word: word.text,
                selectedIndices: selectedIndices,
                showTypes: showResult
            ) { index, letter, isVowel in
                handleLetterTap(index: index, letter: letter, isVowel: isVowel)
            }
            .padding()
            .background(colorManager.palette.cardBackground)
            .cornerRadius(30)
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
    
    // MARK: - Botones de Acción
    private var actionButtons: some View {
        HStack(spacing: 15) {
            AccessibleButton(
                title: "Verificar",
                icon: "✓",
                voiceLabel: "Verificar mi respuesta",
                size: .large,
                backgroundColor: colorManager.palette.successColor
            ) {
                checkAnswer()
            }
            
            AccessibleButton(
                title: "Nueva",
                icon: "🔄",
                voiceLabel: "Cargar nueva palabra",
                size: .large,
                backgroundColor: colorManager.palette.primary
            ) {
                loadNewWord()
            }
        }
    }
    
    // MARK: - Manejar Toque en Letra
    private func handleLetterTap(index: Int, letter: Character, isVowel: Bool) {
        if selectedIndices.contains(index) {
            selectedIndices.remove(index)
        } else {
            selectedIndices.insert(index)
            
            if isVowel {
                speechManager.speak("¡Correcto! \(letter) es una vocal")
                HapticManager.shared.successFeedback()
            } else {
                speechManager.speak("\(letter) es una consonante, busca las vocales")
                HapticManager.shared.errorFeedback()
            }
        }
    }
    
    // MARK: - Verificar Respuesta
    private func checkAnswer() {
        guard let word = currentWord else { return }
        
        let correctIndices = Set(word.vowelIndices)
        isCorrect = selectedIndices == correctIndices
        showResult = true
        
        if isCorrect {
            score += 10
            speechManager.speak("¡Perfecto! Encontraste todas las vocales")
            HapticManager.shared.celebrationPattern()
        } else {
            speechManager.speak("Algunas vocales faltaron o seleccionaste consonantes. Inténtalo de nuevo.")
            HapticManager.shared.errorFeedback()
        }
    }
    
    // MARK: - Cargar Nueva Palabra
    private func loadNewWord() {
        currentWord = WordDatabase.randomWordFromAll()
        selectedIndices = []
        showResult = false
        isCorrect = false
        
        if let word = currentWord {
            speechManager.speak("Encuentra las vocales en la palabra: \(word.text)")
        }
    }
}

// MARK: - Preview
#Preview {
    VowelsGameView(isPresented: .constant(true))
        .environmentObject(ColorManager())
        .environmentObject(SpeechManager())
}