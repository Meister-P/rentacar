//
//  User+CoreDataClass.swift
//  
//
//  Created by Mikk Pavelson on 14/04/2019.
//
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {
    public class func sharedUser() -> User? {
        if let name = staticDataStore.context.entityForType(User.self)?.name {
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: name)
            fetch.fetchLimit = 1
            
            var result: [User]?
            staticDataStore.context.performAndWait { () -> Void in
                do {
                    result = try staticDataStore.context.fetch(fetch) as? [User]
                } catch _ {}
            }
            
            return result?.first
        }
        
        return nil
    }
    
    class func signInUserWith(email: String, password: String) -> User? {
        if let user = findUserWith(email: email, password: password) {
            user.session = staticDataStore.newSession()
            staticDataStore.save()
            
            return user
        }
        
        return nil
    }
    
    class func findUserWith(email: String, password: String? = nil) -> User? {
        var predicate = NSPredicate(format: "email = %@", email)
        
        if let password = password {
            predicate = NSPredicate(format: "email = %@ AND password = %@", email, password)
        }
        
        return staticDataStore.context.fetchFirstEntity(User.self, predicate: predicate)
    }
    
    func logout() {
        dataStore.context.delete(session!)
        session = nil
    }
}
