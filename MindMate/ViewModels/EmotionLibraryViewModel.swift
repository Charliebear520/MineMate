import Foundation

class EmotionLibraryViewModel: ObservableObject {
    @Published var emotionBalls: [EmotionBall] = []
    @Published var latestEmotions: [String: Double] = [:]
    private let geminiService = GeminiAPIService()
    
    init() {
        loadEmotionBalls()
        updateLatestEmotions()
    }
    
    func loadEmotionBalls() {
        // TODO: 從本地存儲加載情緒球數據
        // 這裡暫時使用模擬數據
        emotionBalls = [
            EmotionBall(
                conversation: [],
                emotionAnalysis: EmotionAnalysisResult(
                    emotions: [
                        "happiness": 0.7,
                        "sadness": 0.2,
                        "anger": 0.1
                    ],
                    dominantEmotion: "happiness"
                ),
                summary: "今天心情不錯",
                userNote: nil,
                tags: ["開心", "放鬆"]
            )
        ]
    }
    
    func updateLatestEmotions() {
        // 獲取最新的情緒數據
        if let latest = emotionBalls.last {
            latestEmotions = latest.emotionAnalysis.emotions
        }
    }
    
    func saveEmotionBall(_ emotionBall: EmotionBall) {
        emotionBalls.append(emotionBall)
        // TODO: 保存到本地存儲
        updateLatestEmotions()
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
    
    // 獲取指定時間範圍的情緒數據
    func getEmotionData(for timeRange: EmotionLibraryView.TimeRange) -> [EmotionDataPoint] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch timeRange {
        case .day:
            startDate = calendar.startOfDay(for: now)
        case .week:
            startDate = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        }
        
        // 過濾指定時間範圍內的情緒球
        let filteredBalls = emotionBalls.filter { ball in
            ball.createdAt >= startDate && ball.createdAt <= now
        }
        
        // 將情緒球數據轉換為數據點
        var dataPoints: [EmotionDataPoint] = []
        for ball in filteredBalls {
            for (emotion, value) in ball.emotionAnalysis.emotions {
                dataPoints.append(
                    EmotionDataPoint(
                        date: ball.createdAt,
                        emotion: emotion,
                        value: value
                    )
                )
            }
        }
        
        return dataPoints
    }
    
    func deleteEmotionBall(_ emotionBall: EmotionBall) {
        emotionBalls.removeAll { $0.id == emotionBall.id }
        // TODO: 從本地存儲中刪除
    }
} 