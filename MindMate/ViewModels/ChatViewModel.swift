import Foundation
import SwiftUI

class ChatViewModel: ObservableObject {
    let selectedRole: AIRole
    @Published var messages: [ChatMessage] = []
    @Published var currentInputText: String = ""
    @Published var isAIReplying: Bool = false
    @Published var isRecording: Bool = false
    
    // 新增情緒分析相關屬性
    @Published var showEmotionAnalysisOption: Bool = true
    @Published var shouldNavigateToAnalysis: Bool = false
    @Published var emotionAnalysisResult: EmotionAnalysisResult? = nil
    
    private let geminiService = GeminiChatService()
    private let speechService: SpeechRecognitionServicing
    private let emotionService: EmotionAnalysisServicing = EmotionAnalysisService()
    
    init(
        selectedRole: AIRole,
        speechService: SpeechRecognitionServicing = SpeechRecognitionService()
    ) {
        self.selectedRole = selectedRole
        self.speechService = speechService
    }
    
    func sendMessage(text: String) {
        // 1. 新增用戶訊息
        let userMessage = ChatMessage(
            id: UUID(),
            text: text,
            sender: .user,
            timestamp: Date()
        )
        messages.append(userMessage)
        currentInputText = ""
        isAIReplying = true

        // 2. 準備系統提示詞
        let systemMessage = ChatMessage(
            id: UUID(),
            text: selectedRole.prompt,
            sender: .ai,
            timestamp: Date()
        )
        
        // 3. 將系統提示詞添加到消息歷史的開頭
        var messagesWithSystemPrompt = [systemMessage]
        messagesWithSystemPrompt.append(contentsOf: messages)

        // 4. 呼叫 Gemini
        geminiService.sendMessage(history: messagesWithSystemPrompt, userInput: text) { [weak self] response in
            DispatchQueue.main.async {
                if let response = response {
                    let aiMessage = ChatMessage(
                        id: UUID(),
                        text: response,
                        sender: .ai,
                        timestamp: Date()
                    )
                    self?.messages.append(aiMessage)
                } else {
                    // 你可以在這裡顯示錯誤訊息
                }
                self?.isAIReplying = false
            }
        }
    }
    
    func startVoiceInput() {
        guard !isRecording else { return }
        
        speechService.requestAuthorization { [weak self] authorized in
            guard authorized else {
                print("未获得语音识别权限")
                return
            }
            Task { @MainActor in
                self?.isRecording = true
            }
            self?.speechService.startRecording(
                updateHandler: { [weak self] text in
                    Task { @MainActor in
                        self?.currentInputText = text
                    }
                },
                completionHandler: { [weak self] result in
                    Task { @MainActor in
                        switch result {
                        case .success(let text):
                            self?.currentInputText = text
                        case .failure(let error):
                            print("语音识别错误: \(error)")
                        }
                        self?.isRecording = false
                    }
                }
            )
        }
    }
    
    func stopVoiceInput() {
        speechService.stopRecording()
        isRecording = false
    }
    
    // 新增情緒分析請求方法
    func requestEmotionAnalysis() {
        Task {
            let userMessages = messages.filter { $0.sender == .user }.map { $0.text }
            do {
                let result = try await emotionService.analyzeEmotions(userMessagesText: userMessages)
                await MainActor.run {
                    self.emotionAnalysisResult = result
                    self.shouldNavigateToAnalysis = true
                }
            } catch {
                print("情緒分析失敗: \(error)")
            }
        }
    }
} 