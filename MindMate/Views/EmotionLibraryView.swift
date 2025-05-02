import SwiftUI
import Charts

struct EmotionLibraryView: View {
    @EnvironmentObject var viewModel: EmotionLibraryViewModel
    @State private var selectedTimeRange: TimeRange = .week
    @State private var selectedEmotionBall: EmotionBall?
    @State private var showingDetail = false
    
    enum TimeRange: String, CaseIterable {
        case day = "今天"
        case week = "本週"
        case month = "本月"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 時間範圍選擇器
                Picker("時間範圍", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases, id: \.self) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // 情緒趨勢圖表
                EmotionTrendChartView(emotions: viewModel.latestEmotions)
                    .frame(height: 250)
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(radius: 2)
                
                // 情緒球列表
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 150, maximum: 180), spacing: 16)
                ], spacing: 16) {
                    ForEach(viewModel.emotionBalls) { ball in
                        EmotionBallCard(emotionBall: ball)
                    }
                }
                .padding()
            }
            .padding(.vertical)
        }
        .navigationTitle("情緒庫")
        .sheet(isPresented: $showingDetail) {
            if let ball = selectedEmotionBall {
                EmotionBallDetailView(emotionBall: ball)
            }
        }
    }
}

struct EmotionBallCard: View {
    let emotionBall: EmotionBall
    @State private var showingDetail = false
    
    var body: some View {
        VStack(spacing: 12) {
            // 情緒球視覺化
            EmotionBallView(emotionBall: emotionBall, size: 100)
            
            // 日期和時間
            Text(emotionBall.createdAt.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
                .foregroundColor(.secondary)
            
            // 摘要或備註
            if !emotionBall.summary.isEmpty {
                Text(emotionBall.summary)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            } else if let note = emotionBall.userNote, !note.isEmpty {
                Text(note)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            // 標籤
            if !emotionBall.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(emotionBall.tags), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            EmotionBallDetailView(emotionBall: emotionBall)
        }
    }
}

struct EmotionBallDetailView: View {
    @EnvironmentObject var viewModel: EmotionLibraryViewModel
    let emotionBall: EmotionBall
    @Environment(\.dismiss) private var dismiss
    @State private var showingEdit = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 情緒球視覺化
                    EmotionBallView(emotionBall: emotionBall, size: 200)
                    
                    // 情緒分析
                    VStack(alignment: .leading, spacing: 16) {
                        Text("情緒分析")
                            .font(.headline)
                        
                        ForEach(Array(emotionBall.emotionAnalysis.emotions.sorted { $0.value > $1.value }), id: \.key) { emotion in
                            HStack {
                                Text(emotion.key.localizedEmotionName)
                                    .font(.subheadline)
                                Spacer()
                                Text("\(Int(emotion.value * 100))%")
                                    .font(.subheadline)
                            }
                            ProgressView(value: emotion.value)
                                .tint(emotion.key.emotionColor)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // 對話內容
                    VStack(alignment: .leading, spacing: 16) {
                        Text("對話記錄")
                            .font(.headline)
                        
                        ForEach(emotionBall.conversation) { message in
                            MessageRow(message: message)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("情緒記錄詳情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button("編輯") {
                            showingEdit = true
                        }
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingEdit) {
                EditEmotionBallView(emotionBall: emotionBall, dismiss: dismiss)
                    .environmentObject(viewModel)
            }
            .alert("確定要刪除這筆情緒記錄嗎？", isPresented: $showingDeleteAlert) {
                Button("刪除", role: .destructive) {
                    viewModel.deleteEmotionBall(emotionBall)
                    dismiss()
                }
                Button("取消", role: .cancel) {}
            }
        }
    }
}

// 編輯情緒球頁面
struct EditEmotionBallView: View {
    @EnvironmentObject var viewModel: EmotionLibraryViewModel
    @State var emotionBall: EmotionBall
    let dismiss: DismissAction
    @Environment(\.dismiss) private var dismissSheet
    @State private var userNote: String = ""
    @State private var selectedTags: Set<String> = []
    @State private var newTag: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("預覽") {
                    EmotionBallView(
                        emotionBall: emotionBall,
                        size: 150
                    )
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                Section("備註") {
                    TextEditor(text: $userNote)
                        .frame(height: 100)
                        .onAppear { userNote = emotionBall.userNote ?? "" }
                }
                Section(header: Text("情緒標籤")) {
                    ForEach(Array(emotionBall.tags), id: \.self) { tag in
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
            .navigationTitle("編輯情緒球")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismissSheet()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        let updated = EmotionBall(
                            id: emotionBall.id,
                            conversation: emotionBall.conversation,
                            emotionAnalysis: emotionBall.emotionAnalysis,
                            summary: emotionBall.summary,
                            userNote: userNote,
                            tags: selectedTags,
                            createdAt: emotionBall.createdAt
                        )
                        viewModel.updateEmotionBall(updated)
                        dismissSheet()
                        dismiss()
                    }
                }
            }
            .onAppear {
                userNote = emotionBall.userNote ?? ""
                selectedTags = emotionBall.tags
            }
        }
    }
}

// 預覽
struct EmotionLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            EmotionLibraryView()
        }
    }
} 