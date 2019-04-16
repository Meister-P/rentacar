//
//  Policy+CoreDataProperties.swift
//  
//
//  Created by Mikk Pavelson on 14/04/2019.
//
//

import Foundation
import CoreData


extension Policy {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Policy> {
        return NSFetchRequest<Policy>(entityName: "Policy")
    }

    @NSManaged public var startDate: NSDate?
    @NSManaged public var endDate: NSDate?
    @NSManaged public var car: Car?
    @NSManaged public var user: User?

}
