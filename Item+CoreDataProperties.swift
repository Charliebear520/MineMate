//
//  Item+CoreDataProperties.swift
//  MindMate
//
//  Created by 黃塏峻 on 2025/5/10.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var timestamp: Date?

}

extension Item : Identifiable {

}
