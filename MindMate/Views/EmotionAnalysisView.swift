import SwiftUI

struct EmotionAnalysisView: View {
    let messages: [ChatMessage]
    let emotionResult: EmotionAnalysisResult
    @StateObject private var libraryViewModel = EmotionLibraryViewModel()
    @State private var showingSaveSheet = false
    @State private var userNote: String = ""
    @State private var selectedTags: Set<String> = []
    @State private var aiSummary: String = ""
    @State private var isGeneratingSummary = false
    @State private var showingSuccessAlert = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 情緒分析圖表
                EmotionChartView(emotions: emotionResult.emotions)
                    .frame(height: 200)
                    .padding()
                
                // 保存情緒球按鈕
                Button(action: {
                    showingSaveSheet = true
                }) {
                    Label("保存為情緒球", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // 情緒分析詳情
                VStack(alignment: .leading, spacing: 12) {
                    Text("情緒分析")
                        .font(.headline)
                    
                    ForEach(Array(emotionResult.emotions.sorted(by: { $0.value > $1.value })), id: \.key) { emotion in
                        HStack {
                            Text(emotion.key)
                            Spacer()
                            Text("\(Int(emotion.value * 100))%")
                        }
                        ProgressView(value: emotion.value)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                .padding()
            }
        }
        .navigationTitle("情緒分析")
        .sheet(isPresented: $showingSaveSheet) {
            SaveEmotionBallView(
                messages: messages,
                emotionResult: emotionResult,
                libraryViewModel: libraryViewModel,
                showingSuccessAlert: $showingSuccessAlert,
                dismiss: dismiss
            )
        }
        .alert("保存成功", isPresented: $showingSuccessAlert) {
            Button("確定") {
                dismiss()
            }
        } message: {
            Text("情緒球已成功保存到情緒庫")
        }
    }
}

struct SaveEmotionBallView: View {
    let messages: [ChatMessage]
    let emotionResult: EmotionAnalysisResult
    let libraryViewModel: EmotionLibraryViewModel
    @Binding var showingSuccessAlert: Bool
    let dismiss: DismissAction
    
    @Environment(\.dismiss) private var dismissSheet
    @State private var userNote: String = ""
    @State private var selectedTags: Set<String> = []
    @State private var aiSummary: String = ""
    @State private var isGeneratingSummary = false
    @State private var useAISummary = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("預覽") {
                    EmotionBallView(
                        emotionBall: EmotionBall(
                            conversation: messages,
                            emotionAnalysis: emotionResult,
                            summary: aiSummary,
                            userNote: userNote,
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
                        } else if !aiSummary.isEmpty {
                            Text(aiSummary)
                                .font(.subheadline)
                        }
                    } else {
                        TextEditor(text: $userNote)
                            .frame(height: 100)
                    }
                }
                
                Section("情緒標籤") {
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
                if useAISummary {
                    await generateAISummary()
                }
            }
            .onChange(of: useAISummary) { _, newValue in
                if newValue && aiSummary.isEmpty {
                    Task {
                        await generateAISummary()
                    }
                }
            }
        }
    }
    
    private func generateAISummary() async {
        isGeneratingSummary = true
        do {
            aiSummary = try await libraryViewModel.generateSummary(from: messages)
        } catch {
            print("生成摘要失敗：\(error)")
            aiSummary = "無法生成摘要"
        }
        isGeneratingSummary = false
    }
    
    private func saveEmotionBall() {
        let emotionBall = EmotionBall(
            conversation: messages,
            emotionAnalysis: emotionResult,
            summary: useAISummary ? aiSummary : "",
            userNote: useAISummary ? nil : userNote,
            tags: selectedTags
        )
        
        libraryViewModel.saveEmotionBall(emotionBall)
        dismissSheet()
        showingSuccessAlert = true
    }
}

struct EmotionChartView: View {
    let emotions: [String: Double]
    
    var body: some View {
        // TODO: 實現情緒分析圖表
        Text("情緒分析圖表")
    }
}

// 預覽
struct EmotionAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        EmotionAnalysisView(
            messages: [],
            emotionResult: EmotionAnalysisResult(
                emotions: [
                    "happiness": 0.7,
                    "sadness": 0.2,
                    "anger": 0.1
                ],
                dominantEmotion: "happiness"
            )
        )
    }
} 
