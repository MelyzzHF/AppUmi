//
//  SpeechManager.swift
//  UmiApp
//
//  Gestor de Text-to-Speech para accesibilidad visual
//  Implementa VoiceOver y síntesis de voz nativa
//

import SwiftUI
import AVFoundation

// MARK: - Speech Manager
class SpeechManager: ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    
    @Published var isSpeaking: Bool = false
    
    init() {
        // Configurar la sesión de audio
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error configurando audio session: \(error)")
        }
    }
    
    // MARK: - Hablar texto
    func speak(_ text: String, rate: Float = 0.45) {
        // Detener cualquier habla anterior
        stop()
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "es-MX") // Español de México
        utterance.rate = rate
        utterance.pitchMultiplier = 1.1 // Tono ligeramente más alto para sonar amigable
        utterance.volume = 1.0
        
        isSpeaking = true
        synthesizer.speak(utterance)
        
        // Actualizar estado cuando termine
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(text.count) * 0.08) {
            self.isSpeaking = false
        }
    }
    
    // MARK: - Hablar letra por letra
    func speakLetterByLetter(_ text: String, delay: Double = 0.5) {
        stop()
        
        for (index, letter) in text.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * delay) {
                self.speak(String(letter), rate: 0.3)
            }
        }
    }
    
    // MARK: - Hablar sílabas
    func speakSyllables(_ syllables: [String], delay: Double = 0.8) {
        stop()
        
        for (index, syllable) in syllables.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * delay) {
                self.speak(syllable, rate: 0.35)
            }
        }
    }
    
    // MARK: - Detener habla
    func stop() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        isSpeaking = false
    }
    
    // MARK: - Mensajes predefinidos
    func speakWelcome() {
        speak("¡Bienvenido a Umi! Selecciona un juego para empezar a aprender.")
    }
    
    func speakCorrect() {
        speak("¡Muy bien! ¡Lo lograste!")
    }
    
    func speakIncorrect() {
        speak("¡Casi! Inténtalo de nuevo.")
    }
    
    func speakEncouragement() {
        let messages = [
            "¡Tú puedes!",
            "¡Sigue intentando!",
            "¡Muy bien hecho!",
            "¡Excelente trabajo!",
            "¡Eres increíble!"
        ]
        speak(messages.randomElement() ?? "¡Sigue así!")
    }
}