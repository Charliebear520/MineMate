import Foundation

struct EmotionAnalysisResult: Codable {
    let emotions: [String: Double]
    let dominantEmotion: String?
    
    enum CodingKeys: String, CodingKey {
        case emotions
        case dominantEmotion = "dominant_emotion"
    }
    
    init(emotions: [String: Double], dominantEmotion: String? = nil) {
        self.emotions = emotions
        self.dominantEmotion = dominantEmotion
    }
} 