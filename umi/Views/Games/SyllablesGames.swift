//
//  SyllablesGameView.swift
//  UmiApp
//
//  Juego para aprender a separar palabras en sílabas
//

import SwiftUI

// MARK: - Vista del Juego de Sílabas
struct SyllablesGameView: View {
    @Binding var isPresented: Bool
    
    @EnvironmentObject var colorManager: ColorManager
    @EnvironmentObject var speechManager: SpeechManager
    
    @State private var difficulty: Difficulty = .easy
    @State private var currentWord: Word?
    @State private var highlightedSyllableIndex: Int? = nil
    @State private var score: Int = 0
    @State private var showingResult: Bool = false
    
    var body: some View {
        ZStack {
            // Fondo
            colorManager.palette.background
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                headerSection
                
                // Selector de dificultad
                DifficultySelector(selectedDifficulty: $difficulty)
                    .onChange(of: difficulty) { _, newValue in
                        loadNewWord()
                    }
                
                Spacer()
                
                // Contenido del juego
                if let word = currentWord {
                    gameContent(word: word)
                }
                
                Spacer()
                
                // Botón de nueva palabra
                newWordButton
            }
            .padding()
        }
        .onAppear {
            loadNewWord()
            speechManager.speak("Juego de sílabas. Aprende a separar palabras en partes.")
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            // Botón volver
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
            
            // Título
            Text("🧩 Sílabas")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(colorManager.palette.primary)
            
            Spacer()
            
            // Puntuación
            ScoreDisplay(score: score, streak: nil)
        }
    }
    
    // MARK: - Contenido del Juego
    private func gameContent(word: Word) -> some View {
        VStack(spacing: 24) {
            // Mascota
            UmiMascot(
                mood: .thinking,
                message: "¿Cuántas sílabas tiene esta palabra?"
            )
            
            // Tarjeta de palabra
            WordCard(
                word: word,
                onSpeak: {
                    speechManager.speak(word.text)
                    HapticManager.shared.mediumImpact()
                },
                onSpeakSyllables: {
                    speakSyllablesAnimated(word.syllables)
                }
            )
            
            // Sílabas
            VStack(spacing: 16) {
                Text("Las sílabas son:")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(colorManager.palette.textColor)
                
                SyllableRow(
                    syllables: word.syllables,
                    highlightedIndex: highlightedSyllableIndex
                ) { syllable, index in
                    // Ya maneja el speech internamente
                }
            }
            
            // Información
            SyllableInfo(count: word.syllables.count)
        }
    }
    
    // MARK: - Botón Nueva Palabra
    private var newWordButton: some View {
        AccessibleButton(
            title: "Nueva Palabra",
            icon: "🔄",
            voiceLabel: "Cargar una nueva palabra",
            size: .large,
            backgroundColor: colorManager.palette.primary
        ) {
            loadNewWord()
        }
    }
    
    // MARK: - Cargar Nueva Palabra
    private func loadNewWord() {
        currentWord = WordDatabase.randomWord(difficulty: difficulty)
        highlightedSyllableIndex = nil
        
        if let word = currentWord {
            speechManager.speak("Separa la palabra: \(word.text)")
        }
    }
    
    // MARK: - Hablar Sílabas con Animación
    private func speakSyllablesAnimated(_ syllables: [String]) {
        for (index, syllable) in syllables.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.8) {
                highlightedSyllableIndex = index
                speechManager.speak(syllable, rate: 0.35)
                HapticManager.shared.syllablePattern()
            }
        }
        
        // Quitar highlight al final
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(syllables.count) * 0.8 + 0.5) {
            highlightedSyllableIndex = nil
        }
    }
}

// MARK: - Preview
#Preview {
    SyllablesGameView(isPresented: .constant(true))
        .environmentObject(ColorManager())
        .environmentObject(SpeechManager())
}