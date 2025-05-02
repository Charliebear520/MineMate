import Foundation

class EmotionLibraryViewModel: ObservableObject {
    @Published var emotionBalls: [EmotionBall] = []
    private let geminiService = GeminiAPIService()
    
    init() {
        // TODO: 從本地存儲加載情緒球
        loadEmotionBalls()
    }
    
    private func loadEmotionBalls() {
        // TODO: 實現本地存儲讀取
    }
    
    func saveEmotionBall(_ emotionBall: EmotionBall) {
        emotionBalls.append(emotionBall)
        // TODO: 實現本地存儲保存
    }
    
    func generateSummary(from messages: [ChatMessage]) async throws -> String {
        let prompt = """
        請幫我將以下對話內容總結成一段簡短的日記。
        要求：
        1. 以第一人稱撰寫
        2. 保留對話中的情緒感受
        3. 長度控制在100字以內
        4. 使用溫和的語氣
        
        對話內容：
        \(messages.map { "\($0.sender == .user ? "我" : "AI"): \($0.text)" }.joined(separator: "\n"))
        """
        
        let response = try await geminiService.sendMessage(
            messages: [ChatMessage(
                id: UUID(),
                text: prompt,
                sender: .user,
                timestamp: Date()
            )],
            rolePrompt: "你是一個專業的日記撰寫助手，擅長將對話內容轉換成溫暖的日記。"
        )
        
        return response
    }
    
    func deleteEmotionBall(_ emotionBall: EmotionBall) {
        emotionBalls.removeAll { $0.id == emotionBall.id }
        // TODO: 從本地存儲中刪除
    }
} 