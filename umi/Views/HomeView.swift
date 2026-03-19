//
//  HomeView.swift
//  UmiApp
//
//  Pantalla principal con selección de juegos
//

import SwiftUI

// MARK: - Tipos de Juego
enum GameType: String, CaseIterable, Identifiable {
    // Juegos de Lenguaje (Originales)
    case syllables = "Sílabas"
    case vowels = "Vocales"
    case consonants = "Consonantes"
    case classify = "Clasificar"
    
    // Juegos Básicos (Integrados)
    case colors = "Colores"
    case numbers = "Números"
    case letters = "Letras"
    case shapes = "Formas"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .syllables: return "🧩"
        case .vowels: return "🔴"
        case .consonants: return "🔵"
        case .classify: return "🎯"
        case .colors: return "🎨"
        case .numbers: return "🔢"
        case .letters: return "🔤"
        case .shapes: return "⭐"
        }
    }
    
    var description: String {
        switch self {
        case .syllables: return "Aprende a separar palabras"
        case .vowels: return "Encuentra las vocales"
        case .consonants: return "Encuentra las consonantes"
        case .classify: return "Separa vocales y consonantes"
        case .colors: return "Aprende los colores"
        case .numbers: return "Aprende a contar"
        case .letters: return "Encuentra la letra"
        case .shapes: return "Identifica las formas"
        }
    }
    
    var voiceLabel: String {
        switch self {
        case .syllables: return "Juego de sílabas. Aprende a separar palabras en partes."
        case .vowels: return "Juego de vocales. Encuentra las letras A, E, I, O, U."
        case .consonants: return "Juego de consonantes. Encuentra las letras que no son vocales."
        case .classify: return "Juego de clasificar. Separa las letras en vocales y consonantes."
        case .colors: return "Juego de colores. Aprende a identificar los diferentes colores."
        case .numbers: return "Juego de números. Aprende a contar y reconocer números."
        case .letters: return "Juego de letras. Encuentra la letra correcta del abecedario."
        case .shapes: return "Juego de formas. Identifica figuras geométricas."
        }
    }
}

// MARK: - Vista Principal (Home)
struct HomeView: View {
    @Binding var selectedGame: GameType?
    @State private var showColorSettings = false
    
    @EnvironmentObject var colorManager: ColorManager
    @EnvironmentObject var speechManager: SpeechManager
    
    var body: some View {
        ZStack {
            // Fondo con gradiente
            backgroundGradient
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Mascota Umi
                    UmiMascot(
                        mood: .happy,
                        message: "¡Hola! Soy Umi, tu amiga mariposa. ¡Vamos a aprender juntos!"
                    )
                    .padding(.top, 10)
                    
                    // Grid de juegos
                    gamesGrid
                    
                    // Footer informativo
                    footerSection
                }
                .padding()
            }
        }
        .sheet(isPresented: $showColorSettings) {
            ColorSettingsView()
        }
        .onAppear {
            speechManager.speakWelcome()
        }
    }
    
    // MARK: - Fondo con Gradiente
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                colorManager.palette.background,
                colorManager.palette.background.opacity(0.8),
                colorManager.palette.accent.opacity(0.1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            Spacer()
            
            // Logo
            Text("UMI")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(colorManager.palette.primary)
                .shadow(color: colorManager.palette.primary.opacity(0.3), radius: 4, x: 0, y: 2)
                .accessibilityLabel("Umi, tu amiga de aprendizaje")
                .onTapGesture {
                    speechManager.speak("Umi, tu aplicación de aprendizaje")
                    HapticManager.shared.selectionFeedback()
                }
            
            Spacer()
            
            // Botón de configuración de colores
            CircularAccessibleButton(
                icon: "🎨",
                voiceLabel: "Abrir configuración de colores para daltonismo",
                backgroundColor: colorManager.palette.buttonBackground,
                size: 60
            ) {
                showColorSettings = true
            }
        }
    }
    
    // MARK: - Grid de Juegos
    private var gamesGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 16
        ) {
            ForEach(GameType.allCases) { game in
                GameCard(game: game) {
                    speechManager.speak(game.voiceLabel)
                    HapticManager.shared.mediumImpact()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        selectedGame = game
                    }
                }
            }
        }
        .padding(.top, 10)
    }
    
    // MARK: - Footer
    private var footerSection: some View {
        VStack(spacing: 8) {
            Text("🦋 Toca cualquier elemento para escuchar su descripción")
            Text("📱 Los botones vibran cuando los tocas")
        }
        .font(.system(size: 14, weight: .medium, design: .rounded))
        .foregroundColor(colorManager.palette.textColor.opacity(0.7))
        .multilineTextAlignment(.center)
        .padding()
        .background(colorManager.palette.cardBackground)
        .cornerRadius(20)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Información de accesibilidad. Toca cualquier elemento para escuchar su descripción. Los botones vibran cuando los tocas.")
    }
}

// MARK: - Tarjeta de Juego
struct GameCard: View {
    let game: GameType
    let action: () -> Void
    
    @EnvironmentObject var colorManager: ColorManager
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Icono
                Text(game.icon)
                    .font(.system(size: 50))
                
                // Título
                Text(game.rawValue)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(colorManager.palette.textColor)
                
                // Descripción
                Text(game.description)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(colorManager.palette.textColor.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
            .background(colorManager.palette.cardBackground)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(colorManager.palette.primary, lineWidth: 4)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .contentShape(Rectangle())
        .accessibilityLabel(game.voiceLabel)
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
    }
}

// MARK: - Preview
#Preview {
    HomeView(selectedGame: .constant(nil))
        .environmentObject(ColorManager())
        .environmentObject(SpeechManager())
}
