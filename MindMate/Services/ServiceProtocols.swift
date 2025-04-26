import Foundation
import Speech

protocol GeminiAPIServicing {
    func sendMessage(messages: [ChatMessage], rolePrompt: String) async throws -> String
    func analyzeEmotions(userMessagesText: [String]) async throws -> EmotionAnalysisResult
}

protocol SpeechRecognitionServicing {
    var isAvailable: Bool { get }
    var currentLocale: Locale { get }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void)
    func startRecording(updateHandler: @escaping (String) -> Void, completionHandler: @escaping (Result<String, Error>) -> Void)
    func stopRecording()
}

protocol EmotionAnalysisServicing {
    func analyzeEmotions(userMessagesText: [String]) async throws -> EmotionAnalysisResult
}

// 预留持久化服务协议
// protocol PersistenceServicing {
//     func saveConversation(_ conversation: Conversation) async throws
//     func loadConversations() async throws -> [Conversation]
//     func deleteConversation(_ conversation: Conversation) async throws
// } 