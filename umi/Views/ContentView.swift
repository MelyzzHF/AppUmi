//
//  ContentView.swift
//  UmiApp
//
//  Vista principal que maneja la navegación entre pantallas
//

import SwiftUI

// MARK: - Content View (Navegación Principal)
struct ContentView: View {
    @State private var selectedGame: GameType? = nil
    
    @EnvironmentObject var colorManager: ColorManager
    @EnvironmentObject var speechManager: SpeechManager
    
    var body: some View {
        ZStack {
            // Vista principal o juego seleccionado
            if let game = selectedGame {
                gameView(for: game)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            } else {
                HomeView(selectedGame: $selectedGame)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedGame)
    }
    
    // MARK: - Vista del Juego Seleccionado
    @ViewBuilder
    private func gameView(for game: GameType) -> some View {
        switch game {
        case .syllables:
            SyllablesGameView(isPresented: Binding(
                get: { selectedGame == .syllables },
                set: { if !$0 { selectedGame = nil } }
            ))
            
        case .vowels:
            VowelsGameView(isPresented: Binding(
                get: { selectedGame == .vowels },
                set: { if !$0 { selectedGame = nil } }
            ))
            
        case .consonants:
            ConsonantsGameView(isPresented: Binding(
                get: { selectedGame == .consonants },
                set: { if !$0 { selectedGame = nil } }
            ))
            
        case .classify:
            ClassifyGameView(isPresented: Binding(
                get: { selectedGame == .classify },
                set: { if !$0 { selectedGame = nil } }
            ))
        }
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(ColorManager())
        .environmentObject(SpeechManager())
}