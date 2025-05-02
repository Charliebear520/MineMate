import SwiftUI

extension String {
    var localizedEmotionName: String {
        switch self {
        case "happiness": return "快樂"
        case "sadness": return "悲傷"
        case "anger": return "憤怒"
        case "anxiety": return "焦慮"
        case "calmness": return "平靜"
        default: return self
        }
    }
    
    var emotionColor: Color {
        switch self {
        case "happiness": return .yellow
        case "sadness": return .blue
        case "anger": return .red
        case "anxiety": return .orange
        case "calmness": return .green
        default: return .gray
        }
    }
} 