import SwiftUI

struct ChatView: View {
    let selectedRole: AIRole
    @StateObject private var viewModel: ChatViewModel
    @State private var animate = false
    @State private var borderColors: [Color] = [Color.gray.opacity(0.2)]
    
    init(selectedRole: AIRole) {
        self.selectedRole = selectedRole
        _viewModel = StateObject(wrappedValue: ChatViewModel(selectedRole: selectedRole))
    }
    
    var body: some View {
        ZStack {
            // 聊天室外框情緒漸層＋呼吸動畫
            if let emotion = viewModel.conversationEmotionResult {
                EmotionChatroomBorder(emotions: emotion.emotions, animate: $animate)
            }
            VStack(spacing: 0) {
                // 角色信息
                HStack {
                    Image(systemName: selectedRole.iconName ?? "person.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text(selectedRole.name)
                        .font(.headline)
                    Spacer()
                    
                    // 情绪分析按钮
                    if viewModel.showEmotionAnalysisOption {
                        Button(action: {
                            viewModel.requestEmotionAnalysis()
                        }) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.blue)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .clipShape(Circle())
                        }
                        .disabled(viewModel.messages.filter { $0.sender == .user }.isEmpty)
                        .opacity(viewModel.messages.filter { $0.sender == .user }.isEmpty ? 0.5 : 1.0)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                
                // 消息列表
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageRow(message: message)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.messages) { _, messages in
                        withAnimation {
                            if let lastMessage = messages.last {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // 输入区域
                VStack(spacing: 0) {
                    Divider()
                    HStack(alignment: .bottom, spacing: 12) {
                        // 語音輸入按鈕
                        Button(action: {
                            if viewModel.isRecording {
                                viewModel.stopVoiceInput()
                            } else {
                                viewModel.startVoiceInput()
                            }
                        }) {
                            Image(systemName: viewModel.isRecording ? "waveform" : "mic.fill")
                                .font(.system(size: 24))
                                .foregroundColor(viewModel.isRecording ? .red : .blue)
                                .padding(8)
                        }
                        // 文本输入框
                        TextEditor(text: $viewModel.currentInputText)
                            .frame(minHeight: 36, maxHeight: 100)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                            .padding(.vertical, 6)
                        // 發送按鈕
                        Button(action: {
                            if !viewModel.currentInputText.isEmpty {
                                viewModel.sendMessage(text: viewModel.currentInputText)
                            }
                        }) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(viewModel.currentInputText.isEmpty ? .gray : .blue)
                        }
                        .disabled(viewModel.currentInputText.isEmpty)
                    }
                    .padding(.bottom, 8)
                    .padding(.horizontal)
                    .background(Color(.systemBackground))
                }
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
            .overlay {
                if viewModel.isAIReplying {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.1))
                }
            }
            .navigationDestination(isPresented: $viewModel.shouldNavigateToAnalysis) {
                if let result = viewModel.conversationEmotionResult {
                    EmotionAnalysisView(
                        messages: viewModel.messages,
                        emotionResult: result
                    )
                } else {
                    // 分析中顯示 loading
                    VStack {
                        Spacer()
                        ProgressView("情緒分析中...")
                            .scaleEffect(1.5)
                        Spacer()
                    }
                }
            }
            .padding(8)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
        }
    }
}

// 消息行视图（移除情緒邊框，回歸簡潔）
struct MessageRow: View {
    let message: ChatMessage
    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer()
            }
            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(12)
                    .background(message.sender == .user ? Color.blue : Color(.systemGray5))
                    .foregroundColor(message.sender == .user ? .white : .primary)
                    .cornerRadius(16)
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            if message.sender == .ai {
                Spacer()
            }
        }
    }
}

// 全畫面外框情緒漸層＋明顯呼吸動畫
struct EmotionChatroomBorder: View {
    let emotions: [String: Double]
    @Binding var animate: Bool
    private let colorMap: [String: Color] = [
        "happiness": Color(red: 1.0, green: 0.84, blue: 0.0), // 黃
        "sadness": Color(red: 0.16, green: 0.47, blue: 1.0), // 藍
        "anger": Color(red: 1.0, green: 0.32, blue: 0.32),   // 紅
        "anxiety": Color(red: 1.0, green: 0.57, blue: 0.0),  // 橙
        "calmness": Color(red: 0.0, green: 0.90, blue: 0.46) // 綠
    ]
    var colors: [Color] {
        let sorted = emotions.sorted { $0.value > $1.value }
        let stops = sorted.prefix(3)
        return stops.map { colorMap[$0.key, default: .gray].opacity($0.value) }
    }
    var gradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: colors.isEmpty ? [Color.gray.opacity(0.2)] : colors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    var body: some View {
        RoundedRectangle(cornerRadius: 32)
            .strokeBorder(gradient, lineWidth: animate ? 12 : 4)
            .shadow(color: (colors.first ?? Color.gray).opacity(animate ? 0.5 : 0.18), radius: animate ? 18 : 6)
            .scaleEffect(animate ? 1.025 : 1.0)
            .animation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: animate)
            .padding(2)
    }
}

#Preview {
    ChatView(selectedRole: AIRole(
        id: "therapist",
        name: "心理諮詢師",
        description: "專業的心理諮詢服務",
        prompt: "你是一位專業的心理諮詢師。請告訴我你的感受。",
        iconName: "heart.text.square.fill"
    ))
} 
