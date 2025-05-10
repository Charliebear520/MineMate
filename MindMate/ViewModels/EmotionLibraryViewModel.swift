import Foundation
import CoreData

class EmotionLibraryViewModel: ObservableObject {
    @Published var emotionBalls: [EmotionBall] = [] {
        didSet {
            saveToStorage()
        }
    }
    @Published var latestEmotions: [String: Double] = [:]
    @Published var achievements: [Achievement] = []
    @Published var userProfile: UserProfile?
    private let geminiService = GeminiAPIService()
    private let storageKey = "EmotionBallsStorageKey"
    
    init() {
        loadFromStorage()
        updateLatestEmotions()
    }
    
    // Core Data 讀取成就
    func fetchAchievements(context: NSManagedObjectContext) {
        let request: NSFetchRequest<Achievement> = Achievement.fetchRequest()
        do {
            achievements = try context.fetch(request)
        } catch {
            print("讀取成就失敗：\(error)")
        }
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
    
    // 取得目前用戶（假設只會有一個 UserProfile）
    func fetchUserProfile(context: NSManagedObjectContext) -> UserProfile? {
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        request.fetchLimit = 1
        let profile = (try? context.fetch(request))?.first
        self.userProfile = profile
        return profile
    }
    
    // 新增情緒球並加金幣
    func addEmotionBall(_ ball: EmotionBall, context: NSManagedObjectContext, onReward: (() -> Void)? = nil) {
        emotionBalls.append(ball)
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        request.fetchLimit = 1
        if let profile = (try? context.fetch(request))?.first {
            profile.coins += 100
            do {
                try context.save()
                self.userProfile = profile
                print("coins after save: \(profile.coins)")
                onReward?()
            } catch {
                print("儲存金幣失敗: \(error)")
            }
        }
    }
    
    // 領取成就獎勵
    func claimReward(for achievement: Achievement, context: NSManagedObjectContext) {
        achievement.isRewarded = true
        if let userProfile = fetchUserProfile(context: context) {
            userProfile.coins += achievement.reward
            do {
                try context.save()
                self.userProfile = userProfile
            } catch {
                print("儲存領獎失敗：\(error)")
            }
        }
    }
    
    func updateAchievementProgress(context: NSManagedObjectContext) {
        guard let userProfile = fetchUserProfile(context: context) else { return }
        for achievement in achievements {
            switch achievement.type {
            case "streak":
                achievement.currentValue = userProfile.currentStreak
            case "totalEntries":
                achievement.currentValue = userProfile.totalEntries
            case "emotionOrbs":
                achievement.currentValue = userProfile.emotionOrbs
            case "coins":
                achievement.currentValue = userProfile.coins
            default:
                break
            }
            if achievement.currentValue >= achievement.requirement {
                achievement.isCompleted = true
            }
        }
        try? context.save()
        fetchAchievements(context: context)
    }
} 