import SwiftUI
import CoreData

struct AchievementView: View {
    @FetchRequest(
        entity: Achievement.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Achievement.type, ascending: true)]
    ) var achievements: FetchedResults<Achievement>
    @FetchRequest(
        entity: UserProfile.entity(),
        sortDescriptors: []
    ) var profiles: FetchedResults<UserProfile>
    @Environment(\.managedObjectContext) private var context
    @EnvironmentObject var libraryViewModel: EmotionLibraryViewModel

    var body: some View {
        NavigationView {
            if achievements.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "star")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("目前尚無成就")
                        .font(.title3)
                        .foregroundColor(.gray)
                    Text("完成任務或紀錄情緒來解鎖成就與獎勵！")
                        .font(.body)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            } else {
                List {
                    ForEach(achievements, id: \.type) { achievement in
                        HStack(alignment: .center, spacing: 16) {
                            Image(systemName: achievement.isCompleted ? "star.fill" : "star")
                                .foregroundColor(achievement.isCompleted ? .yellow : .gray)
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(achievement.title ?? "")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text(achievement.desc ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                if achievement.requirement > 0 {
                                    ProgressView(value: Double(achievement.currentValue), total: Double(achievement.requirement))
                                        .accentColor(.yellow)
                                    Text("\(achievement.currentValue)/\(achievement.requirement)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                            if achievement.isCompleted && !achievement.isRewarded {
                                Button("領取") {
                                    claimReward(for: achievement)
                                }
                                .buttonStyle(.borderedProminent)
                            } else if achievement.isRewarded {
                                Text("已領取")
                                    .foregroundColor(.green)
                                    .font(.caption)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(.plain)
                .background(Color(.systemBackground))
                .navigationTitle("成就與獎勵")
                .onAppear {
                    syncAchievementsProgress()
                }
            }
        }
    }

    private func claimReward(for achievement: Achievement) {
        achievement.isRewarded = true
        do {
            try context.save()
        } catch {
            print("Failed to claim reward: \(error)")
        }
    }

    private func syncAchievementsProgress() {
        // 1. 連續簽到天數
        if let signInAchievement = achievements.first(where: { $0.type == "signIn" }) {
            let days = calculateContinuousSignInDays()
            signInAchievement.currentValue = Int64(days)
            signInAchievement.isCompleted = signInAchievement.currentValue >= signInAchievement.requirement
        }
        // 2. 累積情緒球（用 ViewModel 的 emotionBalls.count）
        if let moodAchievement = achievements.first(where: { $0.type == "mood" }) {
            let moodCount = libraryViewModel.emotionBalls.count
            moodAchievement.currentValue = Int64(moodCount)
            moodAchievement.isCompleted = moodAchievement.currentValue >= moodAchievement.requirement
        }
        // 3. 金幣
        if let coinsAchievement = achievements.first(where: { $0.type == "coins" }) {
            let coins = profiles.first?.coins ?? 0
            coinsAchievement.currentValue = coins
            coinsAchievement.isCompleted = coinsAchievement.currentValue >= coinsAchievement.requirement
        }
        do {
            try context.save()
        } catch {
            print("成就進度同步失敗: \(error)")
        }
    }

    // 連續簽到天數的計算方式用 emotionBalls 的日期
    private func calculateContinuousSignInDays() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dates = libraryViewModel.emotionBalls.map { calendar.startOfDay(for: $0.createdAt) }
        let uniqueDates = Array(Set(dates)).sorted(by: >)
        guard !uniqueDates.isEmpty else { return 0 }
        var streak = 0
        var current = today
        for date in uniqueDates {
            if date == current {
                streak += 1
                current = calendar.date(byAdding: .day, value: -1, to: current)!
            } else if date < current {
                break
            }
        }
        return streak
    }
}

#Preview {
    AchievementView().environmentObject(EmotionLibraryViewModel())
}