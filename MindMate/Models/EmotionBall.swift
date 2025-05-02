import Foundation

struct EmotionBall: Identifiable, Codable {
    let id: UUID
    let conversation: [ChatMessage]
    let emotionAnalysis: EmotionAnalysisResult
    let summary: String
    let userNote: String?
    let tags: Set<String>
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        conversation: [ChatMessage],
        emotionAnalysis: EmotionAnalysisResult,
        summary: String = "",
        userNote: String? = nil,
        tags: Set<String> = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.conversation = conversation
        self.emotionAnalysis = emotionAnalysis
        self.summary = summary
        self.userNote = userNote
        self.tags = tags
        self.createdAt = createdAt
    }
}

// 情緒球的視覺效果計算
extension EmotionBall {
    var dominantEmotions: [(emotion: String, strength: Double)] {
        let sortedEmotions = emotionAnalysis.emotions.sorted { $0.value > $1.value }
        return Array(sortedEmotions.prefix(3)).map { ($0.key, $0.value) }
    }
    
    var suggestedTags: Set<String> {
        // 根據情緒分析結果生成建議標籤
        var tags = Set<String>()
        let emotions = emotionAnalysis.emotions
        
        // 添加主要情緒作為標籤
        if let dominantEmotion = emotions.max(by: { $0.value < $1.value }) {
            tags.insert(dominantEmotion.key)
        }
        
        // 可以根據情緒組合添加更多標籤
        if emotions["happiness", default: 0] > 0.7 {
            tags.insert("開心時刻")
        }
        if emotions["sadness", default: 0] > 0.7 {
            tags.insert("難過的日子")
        }
        if emotions["anger", default: 0] > 0.7 {
            tags.insert("憤怒發洩")
        }
        if emotions["anxiety", default: 0] > 0.7 {
            tags.insert("焦慮時光")
        }
        if emotions["calmness", default: 0] > 0.7 {
            tags.insert("平靜時刻")
        }
        
        return tags
    }
} 