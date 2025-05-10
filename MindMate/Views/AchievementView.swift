import SwiftUI

struct AchievementView: View {
    @EnvironmentObject var libraryViewModel: EmotionLibraryViewModel

    var body: some View {
        NavigationView {
            List(libraryViewModel.achievements) { achievement in
                VStack(alignment: .leading, spacing: 8) {
                    Text(achievement.title ?? "")
                        .font(.headline)
                    Text(achievement.desc ?? "")
                        .font(.subheadline)
                    ProgressView(value: achievementProgress(achievement))
                    Text("進度：\(achievementProgressCount(achievement))")
                        .font(.caption)
                    HStack {
                        if achievement.isCompleted && !(achievement.isRewarded) {
                            Button("領取獎勵") {
                                libraryViewModel.claimReward(for: achievement)
                            }
                            .buttonStyle(.borderedProminent)
                        } else if achievement.isRewarded {
                            Text("已領取").foregroundColor(.green)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("成就與獎勵")
        }
    }

    // 計算進度百分比
    func achievementProgress(_ achievement: Achievement) -> Double {
        let current = achievement.currentValue
        let requirement = achievement.requirement
        guard requirement > 0 else { return 0 }
        return Double(current) / Double(requirement)
    }

    // 顯示進度數字
    func achievementProgressCount(_ achievement: Achievement) -> String {
        "\(achievement.currentValue)/\(achievement.requirement)"
    }
}

#Preview {
    AchievementView()
} 