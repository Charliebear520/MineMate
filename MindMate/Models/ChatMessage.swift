import Foundation

enum MessageSender: String, Codable {
    case user
    case ai
}

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let text: String
    let sender: MessageSender
    let timestamp: Date
    var emotionResult: EmotionAnalysisResult?
    
    init(
        id: UUID = UUID(),
        text: String,
        sender: MessageSender,
        timestamp: Date = Date(),
        emotionResult: EmotionAnalysisResult? = nil
    ) {
        self.id = id
        self.text = text
        self.sender = sender
        self.timestamp = timestamp
        self.emotionResult = emotionResult
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.text == rhs.text &&
        lhs.sender == rhs.sender &&
        lhs.timestamp == rhs.timestamp &&
        lhs.emotionResult == rhs.emotionResult
    }
} 