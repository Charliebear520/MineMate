//
//  MindMateApp.swift
//  MindMate
//
//  Created by 黃塏峻 on 2025/4/26.
//

import SwiftUI
import CoreData

func deleteAllAchievements(context: NSManagedObjectContext) {
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Achievement.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    do {
        try context.execute(deleteRequest)
        try context.save()
    } catch {
        print("刪除成就失敗: \(error)")
    }
}

func createDefaultAchievementsIfNeeded(context: NSManagedObjectContext) {
    let titles = ["連續簽到7天", "蒐集10顆情緒球", "達成500金幣"]
    let fetchRequest: NSFetchRequest<Achievement> = Achievement.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "title IN %@", titles)
    do {
        let existing = try context.fetch(fetchRequest)
        let existingTitles = Set(existing.compactMap { $0.title })
        if !existingTitles.contains("連續簽到7天") {
            let a1 = Achievement(context: context)
            a1.title = "連續簽到7天"
            a1.desc = "連續7天有紀錄"
            a1.requirement = 7
            a1.currentValue = 0
            a1.type = "signIn"
            a1.isCompleted = false
            a1.isRewarded = false
        }
        if !existingTitles.contains("蒐集10顆情緒球") {
            let a2 = Achievement(context: context)
            a2.title = "蒐集10顆情緒球"
            a2.desc = "累積10次情緒紀錄"
            a2.requirement = 10
            a2.currentValue = 0
            a2.type = "mood"
            a2.isCompleted = false
            a2.isRewarded = false
        }
        if !existingTitles.contains("達成500金幣") {
            let a3 = Achievement(context: context)
            a3.title = "達成500金幣"
            a3.desc = "金幣數達500"
            a3.requirement = 500
            a3.currentValue = 0
            a3.type = "coins"
            a3.isCompleted = false
            a3.isRewarded = false
        }
        if context.hasChanges {
            try context.save()
        }
    } catch {
        print("初始化成就失敗: \(error)")
    }
}

func createDefaultUserProfileIfNeeded(context: NSManagedObjectContext) {
    let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
    request.fetchLimit = 1
    if (try? context.count(for: request)) == 0 {
        let profile = UserProfile(context: context)
        profile.id = UUID()
        profile.coins = 0
        profile.currentStreak = 0
        profile.emotionOrbs = 0
        profile.totalEntries = 0
        try? context.save()
    }
}

func debugPrintUserProfiles(context: NSManagedObjectContext) {
    let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
    if let profiles = try? context.fetch(request) {
        print("[DEBUG] UserProfile count: \(profiles.count)")
        for profile in profiles {
            print("[DEBUG] Profile id: \(profile.id?.uuidString ?? "") coins: \(profile.coins)")
        }
    } else {
        print("[DEBUG] 無法取得 UserProfile")
    }
}

@main
struct MindMateApp: App {
    let persistenceController = PersistenceController.shared

    init() {
        let context = persistenceController.container.viewContext
        createDefaultUserProfileIfNeeded(context: context)
        deleteAllAchievements(context: context)
        createDefaultAchievementsIfNeeded(context: context)
        debugPrintUserProfiles(context: context)
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(EmotionLibraryViewModel())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
