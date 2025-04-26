import Foundation
import Speech
import AVFoundation

class SpeechRecognitionService: SpeechRecognitionServicing {
    var isAvailable: Bool {
        SFSpeechRecognizer(locale: Locale(identifier: "zh-Hans"))?.isAvailable ?? false
    }
    var currentLocale: Locale {
        SFSpeechRecognizer(locale: Locale(identifier: "zh-Hans"))?.locale ?? Locale(identifier: "zh-Hans")
    }

    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine: AVAudioEngine?
    private var isRecording = false
    
    init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-Hans"))
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { status in
            completion(status == .authorized)
        }
    }
    
    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    func startRecording(updateHandler: @escaping (String) -> Void, completionHandler: @escaping (Result<String, Error>) -> Void) {
        guard !isRecording else { return }
        
        // 设置音频会话
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            completionHandler(.failure(error))
            return
        }
        
        // 创建识别请求
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            completionHandler(.failure(NSError(domain: "SpeechRecognition", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法创建识别请求"])))
            return
        }
        
        // 配置识别请求
        recognitionRequest.shouldReportPartialResults = true
        
        // 设置音频引擎
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            completionHandler(.failure(NSError(domain: "SpeechRecognition", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法创建音频引擎"])))
            return
        }
        
        // 配置音频输入
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        // 启动音频引擎
        audioEngine.prepare()
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            completionHandler(.failure(error))
            return
        }
        
        // 开始识别任务
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let error = error {
                self.stopRecording()
                completionHandler(.failure(error))
                return
            }
            
            if let result = result {
                updateHandler(result.bestTranscription.formattedString)
                
                if result.isFinal {
                    self.stopRecording()
                    completionHandler(.success(result.bestTranscription.formattedString))
                }
            }
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        audioEngine = nil
        
        // 重置音频会话
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("重置音频会话失败: \(error)")
        }
        
        isRecording = false
    }
} 