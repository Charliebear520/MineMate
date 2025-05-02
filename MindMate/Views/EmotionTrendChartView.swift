import SwiftUI
import Charts

struct EmotionTrendChartView: View {
    let emotions: [String: Double]
    @State private var selectedDataPoint: EmotionDataPoint?
    
    // 模擬歷史數據
    private var historicalData: [EmotionDataPoint] {
        let dates = (-6...0).map { days in
            Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date()
        }
        
        let mainEmotions = emotions.sorted { $0.value > $1.value }.prefix(3)
        
        return dates.flatMap { date in
            mainEmotions.map { emotion in
                EmotionDataPoint(
                    date: date,
                    emotion: emotion.key,
                    value: Double.random(in: 0.2...max(emotion.value, 0.8))
                )
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("情緒變化趨勢")
                .font(.headline)
            
            Chart {
                ForEach(historicalData) { dataPoint in
                    LineMark(
                        x: .value("日期", dataPoint.date),
                        y: .value("強度", dataPoint.value)
                    )
                    .foregroundStyle(by: .value("情緒", dataPoint.emotion.localizedEmotionName))
                    .symbol(by: .value("情緒", dataPoint.emotion.localizedEmotionName))
                    .interpolationMethod(.catmullRom)
                }
                
                if let selected = selectedDataPoint {
                    RuleMark(x: .value("選中", selected.date))
                        .foregroundStyle(.gray.opacity(0.3))
                        .lineStyle(.init(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .top) {
                            VStack {
                                Text(selected.emotion.localizedEmotionName)
                                    .font(.caption)
                                    .foregroundColor(selected.emotion.emotionColor)
                                Text("\(Int(selected.value * 100))%")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding(8)
                            .background(Color(.systemBackground))
                            .cornerRadius(8)
                            .shadow(radius: 2)
                        }
                }
            }
            .chartForegroundStyleScale([
                "快樂": Color.yellow,
                "悲傷": Color.blue,
                "憤怒": Color.red,
                "焦慮": Color.orange,
                "平靜": Color.green
            ])
            .chartLegend(position: .bottom, alignment: .center)
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date.shortWeekdayString)
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: .stride(by: 0.2)) { value in
                    AxisValueLabel {
                        if let percentage = value.as(Double.self) {
                            Text("\(Int(percentage * 100))%")
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYScale(domain: 0...1)
            .frame(height: 200)
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let x = value.location.x - geometry[proxy.plotAreaFrame].origin.x
                                    guard let date = proxy.value(atX: x, as: Date.self) else { return }
                                    
                                    let closest = historicalData.min { a, b in
                                        abs(a.date.timeIntervalSince(date)) < abs(b.date.timeIntervalSince(date))
                                    }
                                    selectedDataPoint = closest
                                }
                                .onEnded { _ in
                                    selectedDataPoint = nil
                                }
                        )
                }
            }
        }
    }
}

struct EmotionDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let emotion: String
    let value: Double
}

extension Date {
    var shortWeekdayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: self)
    }
}

// 預覽
struct EmotionTrendChartView_Previews: PreviewProvider {
    static var previews: some View {
        EmotionTrendChartView(emotions: [
            "sadness": 0.6,
            "anxiety": 0.5,
            "anger": 0.3,
            "calmness": 0.1,
            "happiness": 0.05
        ])
        .padding()
        .previewLayout(.sizeThatFits)
    }
} 