//
//  WordModel.swift
//  UmiApp
//
//  Modelo de palabras y base de datos para los juegos educativos
//

import Foundation

// MARK: - Modelo de Palabra
struct Word: Identifiable {
    let id = UUID()
    let text: String
    let syllables: [String]
    
    var letters: [Character] {
        Array(text)
    }
    
    var vowels: [Character] {
        letters.filter { "AEIOUÁÉÍÓÚ".contains($0.uppercased()) }
    }
    
    var consonants: [Character] {
        letters.filter { !"AEIOUÁÉÍÓÚ".contains($0.uppercased()) }
    }
    
    var vowelIndices: [Int] {
        letters.enumerated().compactMap { index, letter in
            "AEIOUÁÉÍÓÚ".contains(letter.uppercased()) ? index : nil
        }
    }
    
    var consonantIndices: [Int] {
        letters.enumerated().compactMap { index, letter in
            !"AEIOUÁÉÍÓÚ".contains(letter.uppercased()) ? index : nil
        }
    }
}

// MARK: - Nivel de Dificultad
enum Difficulty: String, CaseIterable, Identifiable {
    case easy = "Fácil"
    case medium = "Media"
    case hard = "Difícil"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .easy: return "😊"
        case .medium: return "🤔"
        case .hard: return "🧠"
        }
    }
    
    var voiceLabel: String {
        switch self {
        case .easy: return "Nivel fácil, palabras cortas"
        case .medium: return "Nivel medio, palabras de dos sílabas"
        case .hard: return "Nivel difícil, palabras largas"
        }
    }
}

// MARK: - Base de Datos de Palabras
struct WordDatabase {
    
    static let easyWords: [Word] = [
        Word(text: "SOL", syllables: ["SOL"]),
        Word(text: "MAR", syllables: ["MAR"]),
        Word(text: "LUZ", syllables: ["LUZ"]),
        Word(text: "PAN", syllables: ["PAN"]),
        Word(text: "PEZ", syllables: ["PEZ"]),
        Word(text: "DOS", syllables: ["DOS"]),
        Word(text: "MES", syllables: ["MES"]),
        Word(text: "REY", syllables: ["REY"]),
        Word(text: "TEN", syllables: ["TEN"]),
        Word(text: "VER", syllables: ["VER"]),
        Word(text: "SAL", syllables: ["SAL"]),
        Word(text: "FIN", syllables: ["FIN"]),
        Word(text: "VOZ", syllables: ["VOZ"]),
        Word(text: "SER", syllables: ["SER"]),
        Word(text: "DAR", syllables: ["DAR"])
    ]
    
    static let mediumWords: [Word] = [
        Word(text: "CASA", syllables: ["CA", "SA"]),
        Word(text: "MESA", syllables: ["ME", "SA"]),
        Word(text: "LUNA", syllables: ["LU", "NA"]),
        Word(text: "GATO", syllables: ["GA", "TO"]),
        Word(text: "PERRO", syllables: ["PE", "RRO"]),
        Word(text: "LIBRO", syllables: ["LI", "BRO"]),
        Word(text: "NUBE", syllables: ["NU", "BE"]),
        Word(text: "VASO", syllables: ["VA", "SO"]),
        Word(text: "PELO", syllables: ["PE", "LO"]),
        Word(text: "ROJO", syllables: ["RO", "JO"]),
        Word(text: "DADO", syllables: ["DA", "DO"]),
        Word(text: "MANO", syllables: ["MA", "NO"]),
        Word(text: "PATO", syllables: ["PA", "TO"]),
        Word(text: "BOCA", syllables: ["BO", "CA"]),
        Word(text: "TAZA", syllables: ["TA", "ZA"])
    ]
    
    static let hardWords: [Word] = [
        Word(text: "MARIPOSA", syllables: ["MA", "RI", "PO", "SA"]),
        Word(text: "ELEFANTE", syllables: ["E", "LE", "FAN", "TE"]),
        Word(text: "CHOCOLATE", syllables: ["CHO", "CO", "LA", "TE"]),
        Word(text: "ESTRELLA", syllables: ["ES", "TRE", "LLA"]),
        Word(text: "VENTANA", syllables: ["VEN", "TA", "NA"]),
        Word(text: "PELOTA", syllables: ["PE", "LO", "TA"]),
        Word(text: "CAMISA", syllables: ["CA", "MI", "SA"]),
        Word(text: "ZAPATO", syllables: ["ZA", "PA", "TO"]),
        Word(text: "CONEJO", syllables: ["CO", "NE", "JO"]),
        Word(text: "GALLINA", syllables: ["GA", "LLI", "NA"]),
        Word(text: "TORTUGA", syllables: ["TOR", "TU", "GA"]),
        Word(text: "CABALLO", syllables: ["CA", "BA", "LLO"]),
        Word(text: "MANZANA", syllables: ["MAN", "ZA", "NA"]),
        Word(text: "PLATANO", syllables: ["PLA", "TA", "NO"]),
        Word(text: "NARANJA", syllables: ["NA", "RAN", "JA"])
    ]
    
    // MARK: - Obtener palabras por dificultad
    static func words(for difficulty: Difficulty) -> [Word] {
        switch difficulty {
        case .easy: return easyWords
        case .medium: return mediumWords
        case .hard: return hardWords
        }
    }
    
    // MARK: - Obtener palabra aleatoria
    static func randomWord(difficulty: Difficulty) -> Word {
        let words = self.words(for: difficulty)
        return words.randomElement() ?? words[0]
    }
    
    // MARK: - Obtener palabra aleatoria de cualquier nivel
    static func randomWordFromAll() -> Word {
        let allWords = easyWords + mediumWords
        return allWords.randomElement() ?? easyWords[0]
    }
}

// MARK: - Alfabeto
struct Alphabet {
    static let letters: [Character] = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    static let vowels: Set<Character> = Set("AEIOU")
    
    static func isVowel(_ letter: Character) -> Bool {
        vowels.contains(letter.uppercased().first ?? " ")
    }
    
    static func randomLetter() -> Character {
        letters.randomElement() ?? "A"
    }
    
    static func letterType(_ letter: Character) -> String {
        isVowel(letter) ? "vocal" : "consonante"
    }
}