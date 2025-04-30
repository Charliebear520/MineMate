import Foundation

enum Sender {
    case user
    case ai
}

struct ChatMessage: Identifiable, Equatable {
    let id: UUID
    let text: String
    let sender: Sender
    let timestamp: Date
    var isPending: Bool?
    var emotionResult: EmotionAnalysisResult?
    
    init(id: UUID = UUID(), 
         text: String, 
         sender: Sender, 
         timestamp: Date = Date(), 
         isPending: Bool? = nil,
         emotionResult: EmotionAnalysisResult? = nil) {
        self.id = id
        self.text = text
        self.sender = sender
        self.timestamp = timestamp
        self.isPending = isPending
        self.emotionResult = emotionResult
    }
} 