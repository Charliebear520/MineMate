import SwiftUI

struct ChatView: View {
    let selectedRole: AIRole
    @StateObject private var viewModel: ChatViewModel
    @State private var scrollToBottom = false
    
    init(selectedRole: AIRole) {
        self.selectedRole = selectedRole
        _viewModel = StateObject(wrappedValue: ChatViewModel(selectedRole: selectedRole))
    }
    
    var body: some View {
        NavigationStack {
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
                                .foregroundColor(.blue)
                        }
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
                    .onChange(of: viewModel.messages) { _ in
                        withAnimation {
                            if let lastMessage = viewModel.messages.last {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                }
                
                // 输入区域
                VStack(spacing: 0) {
                    Divider()
                    
                    HStack(alignment: .bottom, spacing: 12) {
                        // 语音输入按钮
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
                        
                        // 发送按钮
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
                    .padding()
                }
                .background(Color(.systemBackground))
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
                if let result = viewModel.emotionAnalysisResult {
                    EmotionAnalysisView(result: result)
                }
            }
        }
    }
}

// 消息行视图
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

#Preview {
    ChatView(selectedRole: AIRole(
        id: "therapist",
        name: "心理咨询师",
        description: "专业的心理咨询服务",
        prompt: "你是一位专业的心理咨询师",
        iconName: "heart.text.square.fill"
    ))
} 