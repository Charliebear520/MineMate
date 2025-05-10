import SwiftUI

struct AchievementView: View {
    struct Achievement: Identifiable {
        let id = UUID()
        let title: String
        let description: String
        let progress: Double
        let current: Int
        let requirement: Int
        let isCompleted: Bool
        let isRewarded: Bool
    }
    @State private var achievements: [Achievement] = [
        Achievement(title: "連續登入7天", description: "連續登入7天可獲得100金幣", progress: 0.7, current: 5, requirement: 7, isCompleted: false, isRewarded: false),
        Achievement(title: "儲存10顆情緒球", description: "儲存10顆情緒球可獲得200金幣", progress: 1.0, current: 10, requirement: 10, isCompleted: true, isRewarded: false),
        Achievement(title: "累積1000金幣", description: "累積1000金幣可獲得徽章", progress: 0.5, current: 500, requirement: 1000, isCompleted: false, isRewarded: false)
    ]
    var body: some View {
        NavigationView {
            List(achievements) { achievement in
                VStack(alignment: .leading, spacing: 8) {
                    Text(achievement.title).font(.headline)
                    Text(achievement.description).font(.subheadline)
                    ProgressView(value: achievement.progress)
                    Text("進度：\(achievement.current)/\(achievement.requirement)")
                        .font(.caption)
                    HStack {
                        if achievement.isCompleted && !achievement.isRewarded {
                            Button("領取獎勵") {}
                                .buttonStyle(.borderedProminent)
                        } else if achievement.isRewarded {
                            Text("已領取").foregroundColor(.green)
                        }
                    }
                }.padding(.vertical, 8)
            }
            .navigationTitle("成就與獎勵")
        }
    }
}

#Preview {
    AchievementView()
} 