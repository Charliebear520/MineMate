//
//  UserProfile+CoreDataProperties.swift
//  MindMate
//
//  Created by 黃塏峻 on 2025/5/10.
//
//

import Foundation
import CoreData


extension UserProfile {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfile> {
        return NSFetchRequest<UserProfile>(entityName: "UserProfile")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var coins: Int64
    @NSManaged public var emotionOrbs: Int64
    @NSManaged public var totalEntries: Int64
    @NSManaged public var currentStreak: Int64
    @NSManaged public var lastRecordDate: Date?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var achievements: NSSet?
    @NSManaged public var storeItems: NSSet?

}

// MARK: Generated accessors for achievements
extension UserProfile {

    @objc(addAchievementsObject:)
    @NSManaged public func addToAchievements(_ value: Achievement)

    @objc(removeAchievementsObject:)
    @NSManaged public func removeFromAchievements(_ value: Achievement)

    @objc(addAchievements:)
    @NSManaged public func addToAchievements(_ values: NSSet)

    @objc(removeAchievements:)
    @NSManaged public func removeFromAchievements(_ values: NSSet)

}

// MARK: Generated accessors for storeItems
extension UserProfile {

    @objc(addStoreItemsObject:)
    @NSManaged public func addToStoreItems(_ value: StoreItem)

    @objc(removeStoreItemsObject:)
    @NSManaged public func removeFromStoreItems(_ value: StoreItem)

    @objc(addStoreItems:)
    @NSManaged public func addToStoreItems(_ values: NSSet)

    @objc(removeStoreItems:)
    @NSManaged public func removeFromStoreItems(_ values: NSSet)

}

extension UserProfile : Identifiable {

}
