//
//  Session+CoreDataClass.swift
//  
//
//  Created by Mikk Pavelson on 14/04/2019.
//
//

import Foundation
import CoreData

@objc(Session)
public class Session: NSManagedObject {
    var isValid: Bool {
        return (startDate! as Date).isFuture
    }
}
