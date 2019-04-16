//
//  Car+CoreDataProperties.swift
//  
//
//  Created by Mikk Pavelson on 14/04/2019.
//
//

import Foundation
import CoreData


extension Car {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Car> {
        return NSFetchRequest<Car>(entityName: "Car")
    }

    @NSManaged public var mark: String?
    @NSManaged public var model: String?
    @NSManaged public var imageUrl: String?
    @NSManaged public var thumbnailUrl: String?
    @NSManaged public var policy: Policy?
    @NSManaged var priceDay: NSDecimalNumber

}
