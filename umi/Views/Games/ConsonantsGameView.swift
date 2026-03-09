//
//  ConsonantsGameView.swift
//  UmiApp
//
//  Juego para identificar consonantes en palabras
//

import SwiftUI

// MARK: - Vista del Juego de Consonantes
struct ConsonantsGameView: View {
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
            speechManager.speak("Juego de consonantes. Encuentra las letras que NO son vocales.")
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
            
            Text("🔵 Consonantes")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(colorManager.palette.consonantColor)
            
            Spacer()
            
            ScoreDisplay(score: score, streak: nil)
        }
    }
    
    // MARK: - Tarjeta de Instrucciones
    private var instructionsCard: some View {
        VStack(spacing: 6) {
            Text("Las consonantes son todas las letras")
                .font(.system(size: 14, weight: .medium, design: .rounded))
            
            Text("que NO son vocales")
                .font(.system(size: 16, weight: .bold, design: .rounded))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(colorManager.palette.consonantColor)
        .cornerRadius(20)
        .accessibilityLabel("Las consonantes son todas las letras que NO son A, E, I, O, U")
        .onTapGesture {
            speechManager.speak("Las consonantes son todas las letras que NO son A, E, I, O, U")
            HapticManager.shared.selectionFeedback()
        }
    }
    
    // MARK: - Mascota
    private var mascotSection: some View {
        UmiMascot(
            mood: showResult ? (isCorrect ? .celebrating : .encouraging) : .excited,
            message: showResult
                ? (isCorrect ? "¡Excelente trabajo!" : "¡Casi! Inténtalo de nuevo")
                : "¡Encuentra las consonantes!"
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
            
            if !isVowel {
                speechManager.speak("¡Correcto! \(letter) es una consonante")
                HapticManager.shared.successFeedback()
            } else {
                speechManager.speak("\(letter) es una vocal, busca las consonantes")
                HapticManager.shared.errorFeedback()
            }
        }
    }
    
    // MARK: - Verificar Respuesta
    private func checkAnswer() {
        guard let word = currentWord else { return }
        
        let correctIndices = Set(word.consonantIndices)
        isCorrect = selectedIndices == correctIndices
        showResult = true
        
        if isCorrect {
            score += 10
            speechManager.speak("¡Excelente! Encontraste todas las consonantes")
            HapticManager.shared.celebrationPattern()
        } else {
            speechManager.speak("Revisa tu respuesta. Algunas letras no son consonantes.")
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
            speechManager.speak("Encuentra las consonantes en la palabra: \(word.text)")
        }
    }
}

// MARK: - Preview
#Preview {
    ConsonantsGameView(isPresented: .constant(true))
        .environmentObject(ColorManager())
        .environmentObject(SpeechManager())
}