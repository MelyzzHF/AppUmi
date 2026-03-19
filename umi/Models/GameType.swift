import Foundation

enum GameType: String, CaseIterable, Identifiable {
    // MARK: - Juegos Originales
    case syllables = "Sílabas"
    case vowels = "Vocales"
    case consonants = "Consonantes"
    case classify = "Clasificar"
    
    // MARK: - Juegos Integrados
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
        case .letters: return "Encuentra la letra correcta"
        case .shapes: return "Identifica las formas"
        }
    }
    
    var voiceLabel: String {
        return "Juego de \(self.rawValue). \(self.description)."
    }
}
