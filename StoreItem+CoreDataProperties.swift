//
//  StoreItem+CoreDataProperties.swift
//  MindMate
//
//  Created by 黃塏峻 on 2025/5/10.
//
//

import Foundation
import CoreData


extension StoreItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoreItem> {
        return NSFetchRequest<StoreItem>(entityName: "StoreItem")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var desc: String?
    @NSManaged public var iconName: String?
    @NSManaged public var price: Int64
    @NSManaged public var type: String?
    @NSManaged public var isPurchased: Bool
    @NSManaged public var purchasedAt: Date?
    @NSManaged public var userProfile: UserProfile?

}

extension StoreItem : Identifiable {

}
