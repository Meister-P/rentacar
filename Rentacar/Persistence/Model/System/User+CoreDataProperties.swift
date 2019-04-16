//
//  User+CoreDataProperties.swift
//  
//
//  Created by Mikk Pavelson on 14/04/2019.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastname: String?
    @NSManaged public var password: String?
    @NSManaged public var email: String?
    @NSManaged public var policies: NSSet?
    @NSManaged public var session: Session?

}

// MARK: Generated accessors for policies
extension User {

    @objc(addPoliciesObject:)
    @NSManaged public func addToPolicies(_ value: Policy)

    @objc(removePoliciesObject:)
    @NSManaged public func removeFromPolicies(_ value: Policy)

    @objc(addPolicies:)
    @NSManaged public func addToPolicies(_ values: NSSet)

    @objc(removePolicies:)
    @NSManaged public func removeFromPolicies(_ values: NSSet)

}
