import SwiftUI

struct APITestView: View {
    @State private var response: String = ""
    @State private var emotionResult: EmotionAnalysisResult?
    @State private var isLoading = false
    @State private var error: Error?
    @State private var testText: String = "我今天感到非常開心，因為完成了一個重要的項目！"
    @State private var testMode: TestMode = .basic
    
    private let tester = GeminiAPITester(apiKey: APIKey.default)
    
    enum TestMode {
        case basic
        case emotion
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("API 測試")
                .font(.title)
            
            VStack(alignment: .leading) {
                Text("測試文本：")
                    .font(.headline)
                TextEditor(text: $testText)
                    .frame(height: 100)
                    .border(Color.gray, width: 1)
            }
            
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                HStack(spacing: 20) {
                    Button("測試基本API") {
                        testMode = .basic
                        testBasicAPI()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("測試情緒分析") {
                        testMode = .emotion
                        testEmotionAPI()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            if !response.isEmpty && testMode == .basic {
                Text("API 響應:")
                    .font(.headline)
                ScrollView {
                    Text(response)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .frame(maxHeight: 200)
            }
            
            if let result = emotionResult {
                VStack(alignment: .leading, spacing: 10) {
                    Text("情緒分析結果:")
                        .font(.headline)
                    
                    HStack {
                        Text("主要情緒：")
                        Text(result.dominantEmotion)
                            .foregroundColor(.blue)
                            .bold()
                    }
                    
                    ForEach(Array(result.emotions.sorted(by: { $0.value > $1.value })), id: \.key) { emotion in
                        EmotionBarView(label: emotion.key, value: emotion.value)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            if let error = error {
                Text("錯誤: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
    
    private func testBasicAPI() {
        isLoading = true
        error = nil
        emotionResult = nil
        
        Task {
            do {
                let result = try await tester.testBasicPrompt()
                await MainActor.run {
                    response = result
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    isLoading = false
                }
            }
        }
    }
    
    private func testEmotionAPI() {
        isLoading = true
        error = nil
        response = ""
        
        Task {
            do {
                let result = try await tester.testEmotionAnalysis(text: testText)
                await MainActor.run {
                    emotionResult = result
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    isLoading = false
                }
            }
        }
    }
}

struct EmotionBarView: View {
    let label: String
    let value: Double
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(label)
                    .frame(width: 60, alignment: .leading)
                Text(String(format: "%.2f", value))
                    .frame(width: 40)
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 20)
                            .opacity(0.1)
                            .foregroundColor(.gray)
                        
                        Rectangle()
                            .frame(width: geometry.size.width * value, height: 20)
                            .foregroundColor(.blue)
                    }
                    .cornerRadius(4)
                }
            }
        }
    }
} 