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
    
    private let geminiService: GeminiAPIServicing
    private let speechService: SpeechRecognitionServicing
    private let emotionService: EmotionAnalysisServicing = EmotionAnalysisService(apiKey: "AIzaSyASyd8SELTPYTkteFkNYLfc9wu7rEOC-d0")
    
    init(
        selectedRole: AIRole,
        geminiService: GeminiAPIServicing = GeminiAPIService(apiKey: "AIzaSyASyd8SELTPYTkteFkNYLfc9wu7rEOC-d0"),
        speechService: SpeechRecognitionServicing = SpeechRecognitionService()
    ) {
        self.selectedRole = selectedRole
        self.geminiService = geminiService
        self.speechService = speechService
    }
    
    func sendMessage(text: String) {
        // 1. 创建用户消息并添加到消息列表
        let userMessage = ChatMessage(
            id: UUID(),
            text: text,
            sender: .user,
            timestamp: Date()
        )
        messages.append(userMessage)
        
        // 2. 清空输入框
        currentInputText = ""
        
        // 3. 设置 AI 正在回复状态
        isAIReplying = true
        
        // 4. 异步调用 Gemini API
        Task {
            do {
                let response = try await geminiService.sendMessage(
                    messages: self.messages,
                    rolePrompt: selectedRole.prompt
                )
                
                // 5. 处理成功响应
                await MainActor.run {
                    let aiMessage = ChatMessage(
                        id: UUID(),
                        text: response,
                        sender: .ai,
                        timestamp: Date()
                    )
                    messages.append(aiMessage)
                }
            } catch {
                // 6. 处理错误
                print("发送消息错误: \(error)")
            }
            
            // 7. 重置 AI 回复状态
            await MainActor.run {
                isAIReplying = false
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