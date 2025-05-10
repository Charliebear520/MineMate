import SwiftUI
import CoreData

struct EmotionAnalysisView: View {
    let messages: [ChatMessage]
    let emotionResult: EmotionAnalysisResult
    @EnvironmentObject var libraryViewModel: EmotionLibraryViewModel
    @State private var showingSaveSheet = false
    @State private var showingSuccessAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 當前情緒狀態
                EmotionStateView(emotions: emotionResult.emotions)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 2)
                
                // 整合的舒緩建議和工具
                EmotionSupportView(emotions: emotionResult.emotions)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 2)
                
                // 保存按鈕
                Button(action: {
                    showingSaveSheet = true
                }) {
                    Label("保存到情緒庫", systemImage: "square.and.arrow.down.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("情緒分析與建議")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSaveSheet) {
            SaveEmotionBallView(
                messages: messages,
                emotionResult: emotionResult,
                showingSuccessAlert: $showingSuccessAlert,
                dismiss: dismiss
            )
        }
        .alert("保存成功", isPresented: $showingSuccessAlert) {
            Button("確定") {
                dismiss()
            }
        } message: {
            Text("情緒記錄已保存到情緒庫，你可以在那裡查看情緒變化趨勢")
        }
    }
}

// 當前情緒狀態視圖
struct EmotionStateView: View {
    let emotions: [String: Double]
    
    // 正規化後的情緒百分比
    private var normalizedEmotions: [(String, Double)] {
        let total = emotions.values.reduce(0, +)
        guard total > 0 else { return emotions.map { ($0.key, 0.0) } }
        return emotions.map { ($0.key, $0.value / total) }.sorted { $0.1 > $1.1 }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("當前情緒狀態")
                .font(.headline)
            
            // 只顯示條形圖，無主情緒標籤
            VStack(spacing: 12) {
                ForEach(normalizedEmotions, id: \.0) { emotion in
                    HStack {
                        Text(emotion.0.localizedEmotionName)
                            .font(.subheadline)
                        Spacer()
                        Text("\(Int(emotion.1 * 100))%")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    ProgressView(value: emotion.1)
                        .tint(emotion.0.emotionColor)
                }
            }
        }
    }
}

// 整合的舒緩建議和工具視圖
struct EmotionSupportView: View {
    let emotions: [String: Double]
    @State private var selectedTool: EmotionTool?
    
    private var dominantEmotions: [(String, Double)] {
        emotions.sorted { $0.value > $1.value }.prefix(2).map { ($0.key, $0.value) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 舒緩建議標題
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .foregroundColor(.red)
                Text("為你準備的建議")
                    .font(.headline)
            }
            
            // 立即舒緩建議
            VStack(alignment: .leading, spacing: 12) {
                ForEach(suggestionsForEmotions(dominantEmotions.map { $0.0 }), id: \.self) { suggestion in
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(suggestion)
                            .font(.subheadline)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            Divider()
                .padding(.vertical, 8)
            
            // 深度練習工具
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "figure.mind.and.body")
                        .foregroundColor(.blue)
                    Text("深度練習")
                        .font(.headline)
                }
                
                ForEach(toolsForEmotions(dominantEmotions.map { $0.0 }), id: \.title) { tool in
                    Button(action: {
                        selectedTool = tool
                    }) {
                        HStack {
                            Image(systemName: tool.iconName)
                                .foregroundColor(tool.color)
                            VStack(alignment: .leading) {
                                Text(tool.title)
                                    .font(.subheadline)
                                    .bold()
                                Text(tool.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .sheet(item: $selectedTool) { tool in
            // TODO: 實現具體工具頁面
            Text(tool.title)
        }
    }
    
    private func suggestionsForEmotions(_ emotions: [String]) -> [String] {
        // 保持原有的建議邏輯
        var suggestions: [String] = []
        for emotion in emotions {
            switch emotion {
            case "sadness":
                suggestions += [
                    "進行15分鐘輕度運動",
                    "與親友聊天分享感受",
                    "聆聽愉快的音樂"
                ]
            case "anxiety":
                suggestions += [
                    "做幾次深呼吸練習",
                    "寫下當前的擔憂",
                    "放鬆肌肉練習"
                ]
            case "anger":
                suggestions += [
                    "暫時離開壓力環境",
                    "數到10冷靜一下",
                    "喝一杯溫水"
                ]
            case "happiness":
                suggestions += [
                    "分享快樂給他人",
                    "記錄美好時刻",
                    "保持感恩的心"
                ]
            case "calmness":
                suggestions += [
                    "保持當前的平靜",
                    "享受寧靜時刻",
                    "進行冥想練習"
                ]
            default:
                break
            }
        }
        return Array(Set(suggestions)).prefix(3).map { $0 }
    }
    
    private func toolsForEmotions(_ emotions: [String]) -> [EmotionTool] {
        // 保持原有的工具邏輯
        var tools: [EmotionTool] = []
        for emotion in emotions {
            switch emotion {
            case "sadness", "anxiety":
                tools += [
                    EmotionTool(
                        title: "引導式呼吸",
                        description: "幫助你放鬆身心的呼吸練習",
                        iconName: "lungs.fill",
                        color: .blue
                    ),
                    EmotionTool(
                        title: "正念冥想",
                        description: "10分鐘的正念練習",
                        iconName: "brain.head.profile",
                        color: .purple
                    )
                ]
            case "anger":
                tools += [
                    EmotionTool(
                        title: "情緒日記",
                        description: "記錄和理解你的憤怒",
                        iconName: "book.fill",
                        color: .red
                    ),
                    EmotionTool(
                        title: "放鬆練習",
                        description: "漸進式肌肉放鬆",
                        iconName: "figure.walk",
                        color: .green
                    )
                ]
            default:
                tools += [
                    EmotionTool(
                        title: "心情回顧",
                        description: "查看情緒變化趨勢",
                        iconName: "chart.line.uptrend.xyaxis",
                        color: .orange
                    )
                ]
            }
        }
        return Array(Set(tools)).prefix(3).map { $0 }
    }
}

// 預覽
struct EmotionAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EmotionAnalysisView(
                messages: [],
                emotionResult: EmotionAnalysisResult(
                    emotions: [
                        "happiness": 0.7,
                        "sadness": 0.2,
                        "anger": 0.1,
                        "anxiety": 0.5,
                        "calmness": 0.3
                    ],
                    dominantEmotion: "happiness"
                )
            )
        }
    }
}

struct SaveEmotionBallView: View {
    let messages: [ChatMessage]
    let emotionResult: EmotionAnalysisResult
    @EnvironmentObject var libraryViewModel: EmotionLibraryViewModel
    @Binding var showingSuccessAlert: Bool
    let dismiss: DismissAction
    
    @Environment(\.dismiss) private var dismissSheet
    @State private var userNote: String = ""
    @State private var selectedTags: Set<String> = []
    @State private var aiSummary: String = ""
    @State private var isGeneratingSummary = false
    @State private var useAISummary = true
    @State private var newTag: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("預覽") {
                    EmotionBallView(
                        emotionBall: EmotionBall(
                            conversation: messages,
                            emotionAnalysis: emotionResult,
                            summary: useAISummary ? aiSummary : userNote,
                            userNote: useAISummary ? nil : userNote,
                            tags: selectedTags
                        ),
                        size: 150
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                Section("摘要選項") {
                    Toggle("使用AI摘要", isOn: $useAISummary)
                    if useAISummary {
                        if isGeneratingSummary {
                            ProgressView("生成摘要中...")
                        } else {
                            Text(aiSummary.isEmpty ? "無AI摘要" : aiSummary)
                                .font(.subheadline)
                        }
                    } else {
                        TextEditor(text: $userNote)
                            .frame(height: 100)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
                    }
                }
                
                Section(header: Text("情緒標籤")) {
                    // AI建議標籤
                    let suggestedTags = EmotionBall(
                        conversation: messages,
                        emotionAnalysis: emotionResult
                    ).suggestedTags
                    ForEach(Array(suggestedTags), id: \.self) { tag in
                        Toggle(tag, isOn: Binding(
                            get: { selectedTags.contains(tag) },
                            set: { isSelected in
                                if isSelected {
                                    selectedTags.insert(tag)
                                } else {
                                    selectedTags.remove(tag)
                                }
                            }
                        ))
                    }
                    // 用戶自訂標籤
                    HStack {
                        TextField("新增標籤", text: $newTag)
                        Button(action: {
                            let trimmed = newTag.trimmingCharacters(in: .whitespaces)
                            guard !trimmed.isEmpty else { return }
                            selectedTags.insert(trimmed)
                            newTag = ""
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                    // 已選標籤顯示
                    if !selectedTags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(Array(selectedTags), id: \.self) { tag in
                                    HStack(spacing: 4) {
                                        Text(tag)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .foregroundColor(.blue)
                                            .cornerRadius(8)
                                        Button(action: { selectedTags.remove(tag) }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("保存情緒球")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismissSheet()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        saveEmotionBall()
                    }
                }
            }
            .task {
                if useAISummary && aiSummary.isEmpty {
                    await generateAISummary()
                }
            }
            .onChange(of: useAISummary) { _, newValue in
                if newValue && aiSummary.isEmpty {
                    Task { await generateAISummary() }
                }
            }
        }
    }
    
    private func generateAISummary() async {
        isGeneratingSummary = true
        do {
            aiSummary = try await libraryViewModel.generateSummary(from: messages)
        } catch {
            aiSummary = "無法生成AI摘要"
        }
        isGeneratingSummary = false
    }
    
    private func saveEmotionBall() {
        let emotionBall = EmotionBall(
            conversation: messages,
            emotionAnalysis: emotionResult,
            summary: useAISummary ? aiSummary : userNote,
            userNote: useAISummary ? nil : userNote,
            tags: selectedTags
        )
        libraryViewModel.saveEmotionBall(emotionBall)
        dismissSheet()
        showingSuccessAlert = true
    }
}

// AchievementType.swift
enum AchievementType: String {
    case streak = "連續記錄"
    case totalEntries = "總記錄數"
    case emotionOrbs = "情緒球收集"
    case coins = "金幣收集"
    
    var localizedName: String {
        switch self {
        case .streak: return "連續記錄"
        case .totalEntries: return "總記錄數"
        case .emotionOrbs: return "情緒球收集"
        case .coins: return "金幣收集"
        }
    }
}

// StoreItemType.swift
enum StoreItemType: String {
    case theme = "主題"
    case animation = "動畫效果"
    case feature = "功能"
    
    var localizedName: String {
        switch self {
        case .theme: return "主題"
        case .animation: return "動畫效果"
        case .feature: return "功能"
        }
    }
}

// AchievementManager.swift
class AchievementManager {
    static let shared = AchievementManager()
    
    // 預設成就列表
    let defaultAchievements: [(AchievementType, String, String, Int64, Int64)] = [
        (.streak, "初學者", "連續記錄3天", 3, 50),
        (.streak, "持之以恆", "連續記錄7天", 7, 100),
        (.streak, "習慣養成", "連續記錄30天", 30, 500),
        (.totalEntries, "記錄新手", "完成10次記錄", 10, 50),
        (.totalEntries, "記錄達人", "完成50次記錄", 50, 200),
        (.emotionOrbs, "情緒收集者", "收集10個情緒球", 10, 100),
        (.emotionOrbs, "情緒大師", "收集50個情緒球", 50, 300),
        (.coins, "小富翁", "累積1000金幣", 1000, 100),
        (.coins, "大富翁", "累積5000金幣", 5000, 500)
    ]
    
    // 檢查並更新成就
    func checkAchievements(for profile: UserProfile) {
        let context = profile.managedObjectContext!
        
        for (type, title, description, requirement, reward) in defaultAchievements {
            let fetchRequest: NSFetchRequest<Achievement> = Achievement.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "title == %@ AND userProfile == %@", title, profile)
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.isEmpty {
                    // 創建新成就
                    let achievement = Achievement(context: context)
                    achievement.id = UUID()
                    achievement.title = title
                    achievement.desc = description
                    achievement.type = type.rawValue
                    achievement.requirement = requirement
                    achievement.reward = reward
                    achievement.isCompleted = false
                    achievement.userProfile = profile
                }
            } catch {
                print("檢查成就失敗：\(error)")
            }
        }
        
        // 更新成就狀態
        updateAchievementStatus(for: profile)
    }
    
    // 更新成就狀態
    private func updateAchievementStatus(for profile: UserProfile) {
        guard let achievements = profile.achievements as? Set<Achievement> else { return }
        for achievement in achievements {
            if achievement.isCompleted { continue }
            let requirement = achievement.requirement
            var currentValue: Int64 = 0
            switch AchievementType(rawValue: achievement.type ?? "") {
            case .streak:
                currentValue = profile.currentStreak
            case .totalEntries:
                currentValue = profile.totalEntries
            case .emotionOrbs:
                currentValue = profile.emotionOrbs
            case .coins:
                currentValue = profile.coins
            case .none:
                continue
            }
            if currentValue >= requirement {
                achievement.isCompleted = true
                achievement.completedAt = Date()
                profile.addCoins(achievement.reward)
            }
        }
    }
}

// StoreManager.swift
class StoreManager {
    static let shared = StoreManager()
    
    // 預設商店項目
    let defaultStoreItems: [(StoreItemType, String, String, String, Int64)] = [
        (.theme, "深色主題", "解鎖深色模式", "moon.fill", 500),
        (.theme, "彩虹主題", "解鎖彩虹主題", "rainbow", 1000),
        (.animation, "煙花效果", "解鎖煙花動畫", "sparkles", 300),
        (.animation, "心形效果", "解鎖心形動畫", "heart.fill", 300),
        (.feature, "進階統計", "解鎖進階統計功能", "chart.bar.fill", 2000),
        (.feature, "自訂標籤", "解鎖自訂標籤功能", "tag.fill", 1000)
    ]
    
    // 初始化商店項目
    func initializeStoreItems(for profile: UserProfile) {
        let context = profile.managedObjectContext!
        
        for (type, name, description, iconName, price) in defaultStoreItems {
            let fetchRequest: NSFetchRequest<StoreItem> = StoreItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name == %@ AND userProfile == %@", name, profile)
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.isEmpty {
                    let item = StoreItem(context: context)
                    item.id = UUID()
                    item.name = name
                    item.desc = description
                    item.iconName = iconName
                    item.price = price
                    item.type = type.rawValue
                    item.isPurchased = false
                    item.userProfile = profile
                }
            } catch {
                print("初始化商店項目失敗：\(error)")
            }
        }
    }
    
    // 購買商店項目
    func purchaseItem(_ item: StoreItem, for profile: UserProfile) -> Bool {
        guard !item.isPurchased else { return false }
        
        if profile.spendCoins(item.price) {
            item.isPurchased = true
            item.purchasedAt = Date()
            return true
        }
        
        return false
    }
}

extension UserProfile {
    func spendCoins(_ amount: Int64) -> Bool {
        guard coins >= amount else { return false }
        coins -= amount
        updatedAt = Date()
        return true
    }
    
    func addCoins(_ amount: Int64) {
        self.coins += amount
        self.updatedAt = Date()
    }
} 
