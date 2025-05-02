import Foundation

class EmotionLibraryViewModel: ObservableObject {
    @Published var emotionBalls: [EmotionBall] = [] {
        didSet {
            saveToStorage()
        }
    }
    @Published var latestEmotions: [String: Double] = [:]
    private let geminiService = GeminiAPIService()
    private let storageKey = "EmotionBallsStorageKey"
    
    init() {
        loadFromStorage()
        updateLatestEmotions()
    }
    
    // 永久保存
    private func saveToStorage() {
        do {
            let data = try JSONEncoder().encode(emotionBalls)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("儲存情緒球失敗：\(error)")
        }
    }
    
    // 載入
    private func loadFromStorage() {
        if let data = UserDefaults.standard.data(forKey: storageKey) {
            do {
                emotionBalls = try JSONDecoder().decode([EmotionBall].self, from: data)
            } catch {
                print("載入情緒球失敗：\(error)")
                emotionBalls = []
            }
        } else {
            emotionBalls = []
        }
    }
    
    func loadEmotionBalls() {
        loadFromStorage()
    }
    
    func updateLatestEmotions() {
        if let latest = emotionBalls.last {
            latestEmotions = latest.emotionAnalysis.emotions
        }
    }
    
    func saveEmotionBall(_ emotionBall: EmotionBall) {
        emotionBalls.append(emotionBall)
        updateLatestEmotions()
    }
    
    func updateEmotionBall(_ emotionBall: EmotionBall) {
        if let idx = emotionBalls.firstIndex(where: { $0.id == emotionBall.id }) {
            emotionBalls[idx] = emotionBall
            updateLatestEmotions()
        }
    }
    
    func deleteEmotionBall(_ emotionBall: EmotionBall) {
        emotionBalls.removeAll { $0.id == emotionBall.id }
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
        let filteredBalls = emotionBalls.filter { ball in
            ball.createdAt >= startDate && ball.createdAt <= now
        }
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
} 