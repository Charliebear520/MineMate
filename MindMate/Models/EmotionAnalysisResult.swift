import Foundation

struct EmotionAnalysisResult: Codable, Equatable {
    struct Emotions: Codable {
        let happiness: Double
        let sadness: Double
        let anger: Double
        let anxiety: Double
        let calmness: Double
    }
    
    let emotions: [String: Double]
    let dominantEmotion: String
    
    enum CodingKeys: String, CodingKey {
        case emotions
        case dominantEmotion = "dominant_emotion"
    }
    
    init(emotions: [String: Double], dominantEmotion: String? = nil) {
        self.emotions = emotions
        self.dominantEmotion = dominantEmotion ?? emotions.max(by: { $0.value < $1.value })?.key ?? "neutral"
    }
    
    static func == (lhs: EmotionAnalysisResult, rhs: EmotionAnalysisResult) -> Bool {
        lhs.emotions == rhs.emotions &&
        lhs.dominantEmotion == rhs.dominantEmotion
    }
} 