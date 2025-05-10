//
//  Achievement+CoreDataProperties.swift
//  MindMate
//
//  Created by 黃塏峻 on 2025/5/10.
//
//

import Foundation
import CoreData


extension Achievement {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Achievement> {
        return NSFetchRequest<Achievement>(entityName: "Achievement")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var desc: String?
    @NSManaged public var iconName: String?
    @NSManaged public var type: String?
    @NSManaged public var requirement: Int64
    @NSManaged public var reward: Int64
    @NSManaged public var isCompleted: Bool
    @NSManaged public var completedAt: Date?
    @NSManaged public var userProfile: UserProfile?

}

extension Achievement : Identifiable {

}
