import SwiftUI

struct VideoGeneratorView: View {
    @EnvironmentObject var libraryViewModel: EmotionLibraryViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedEmotionBalls: Set<EmotionBall> = []
    @State private var generatedPrompt: String = ""
    @State private var isGeneratingPrompt = false
    @State private var isGeneratingVideo = false
    @State private var generatedVideoURL: URL?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var previewEmotionBall: EmotionBall? = nil
    @State private var showInfo = false
    @State private var showPromptSheet = false
    
    private let veoService = VeoAPIService()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 情绪球选择区域
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(libraryViewModel.emotionBalls) { emotionBall in
                            EmotionBallSelectionCard(
                                emotionBall: emotionBall,
                                isSelected: selectedEmotionBalls.contains(emotionBall),
                                onTap: {
                                    if selectedEmotionBalls.contains(emotionBall) {
                                        selectedEmotionBalls.remove(emotionBall)
                                    } else {
                                        selectedEmotionBalls.insert(emotionBall)
                                    }
                                },
                                onLongPress: {
                                    previewEmotionBall = emotionBall
                                }
                            )
                        }
                    }
                    .padding()
                }
                
                // 生成提示按钮
                if !selectedEmotionBalls.isEmpty {
                    HStack(spacing: 8) {
                        Button(action: {
                            Task {
                                await generatePrompt()
                            }
                        }) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                Text(generatedPrompt.isEmpty ? "生成故事線" : "重新生成故事線")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(isGeneratingPrompt)
                        // info icon
                        Button(action: { showInfo = true }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                                .font(.title3)
                        }
                        .accessibilityLabel("故事線說明")
                    }
                    .padding(.horizontal)
                }
                
                // 显示生成的提示
                if !generatedPrompt.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("故事線預覽")
                            .font(.headline)
                        Button(action: { showPromptSheet = true }) {
                            HStack(alignment: .top) {
                                Text(generatedPrompt)
                                    .foregroundColor(.primary)
                                    .lineLimit(2)
                                    .truncationMode(.tail)
                                Spacer()
                                Image(systemName: "doc.text.magnifyingglass")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        // 生成视频按钮
                        Button(action: {
                            Task {
                                await generateVideo()
                            }
                        }) {
                            HStack {
                                Image(systemName: "video.fill")
                                Text("生成影片")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(isGeneratingVideo)
                    }
                    .padding()
                }
                
                // 显示生成的视频
                if let videoURL = generatedVideoURL {
                    VideoPlayer(url: videoURL)
                        .frame(height: 200)
                        .cornerRadius(10)
                        .padding()
                }
            }
            .navigationTitle("生成情緒回顧")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
            .alert("錯誤", isPresented: $showError) {
                Button("確定", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .alert("什麼是生成故事線？", isPresented: $showInfo) {
                Button("我知道了", role: .cancel) { }
            } message: {
                Text("根據你選擇的情緒球內容，AI會自動生成一段有故事感的文字，作為影片的腳本。")
            }
            .sheet(item: $previewEmotionBall) { ball in
                EmotionBallPreviewSheet(emotionBall: $previewEmotionBall)
            }
            .sheet(isPresented: $showPromptSheet) {
                StoryPromptFullSheet(prompt: generatedPrompt, onClose: { showPromptSheet = false })
            }
        }
    }
    
    private func generatePrompt() async {
        isGeneratingPrompt = true
        do {
            generatedPrompt = try await veoService.generateStoryPrompt(from: Array(selectedEmotionBalls))
        } catch {
            errorMessage = "生成故事線失敗：\(error.localizedDescription)"
            showError = true
        }
        isGeneratingPrompt = false
    }
    
    private func generateVideo() async {
        isGeneratingVideo = true
        do {
            generatedVideoURL = try await veoService.generateVideo(prompt: generatedPrompt)
        } catch {
            errorMessage = "生成影片失敗：\(error.localizedDescription)"
            showError = true
        }
        isGeneratingVideo = false
    }
}

struct EmotionBallSelectionCard: View {
    let emotionBall: EmotionBall
    let isSelected: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    var body: some View {
        VStack {
            EmotionBallView(emotionBall: emotionBall, size: 80)
            
            Text(emotionBall.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
            
            if !emotionBall.summary.isEmpty {
                Text(emotionBall.summary)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.gray.opacity(0.2), lineWidth: 2)
        )
        .onTapGesture(perform: onTap)
        .onLongPressGesture(perform: onLongPress)
    }
}

struct EmotionBallPreviewSheet: View {
    @Binding var emotionBall: EmotionBall?
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let ball = emotionBall {
                        EmotionBallView(emotionBall: ball, size: 120)
                        Text("日期：\(ball.createdAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if !ball.summary.isEmpty {
                            Text("摘要：\n\(ball.summary)")
                                .font(.body)
                        }
                        if let note = ball.userNote, !note.isEmpty {
                            Text("備註：\n\(note)")
                                .font(.body)
                        }
                        if !ball.conversation.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("對話片段：")
                                    .font(.headline)
                                ForEach(ball.conversation) { msg in
                                    HStack(alignment: .top) {
                                        Text(msg.sender == .user ? "我：" : "AI：")
                                            .bold()
                                        Text(msg.text)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("情緒球詳情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") {
                        emotionBall = nil
                    }
                }
            }
        }
    }
}

struct VideoPlayer: View {
    let url: URL
    
    var body: some View {
        // TODO: 实现视频播放器
        Text("视频播放器")
    }
}

struct StoryPromptFullSheet: View {
    let prompt: String
    let onClose: () -> Void
    @State private var showCopyAlert = false
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("完整故事線")
                        .font(.title2)
                        .bold()
                    Text(prompt)
                        .font(.body)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    Button(action: {
                        UIPasteboard.general.string = prompt
                        showCopyAlert = true
                    }) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("複製全文")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .navigationTitle("故事線全文")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") {
                        onClose()
                    }
                }
            }
            .alert("已複製", isPresented: $showCopyAlert) {
                Button("好", role: .cancel) { }
            } message: {
                Text("故事線已複製到剪貼簿")
            }
        }
    }
}

#Preview {
    VideoGeneratorView()
        .environmentObject(EmotionLibraryViewModel())
} 