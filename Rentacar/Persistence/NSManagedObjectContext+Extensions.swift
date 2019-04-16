//
//  NSManagedObjectContext+Extensions.swift
//  Rentacar
//
//  Created by Mikk Pavelson on 08/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import UIKit
import CoreData

public extension NSPredicate {
    static let truePredicate = NSPredicate(format: "TRUEPREDICATE")
}

public extension NSObject {
    var dataStore: DataStore {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.appDataStore
    }
    
    static var staticDataStore: DataStore {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.appDataStore
    }
}

public extension NSManagedObject {
    public class func entityName() -> String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}

extension NSFetchRequestResult {
    public static func entityName() -> String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}

extension NSManagedObjectContext {
    public func insertEntity<T: NSManagedObject>() -> T {
        return NSEntityDescription.insertNewObject(forEntityName: T.entityName(), into: self) as! T
    }
    
    func entityForType<T: NSManagedObject>(_ type: T.Type) -> NSEntityDescription? {
        if let coordinator = self.persistentStoreCoordinator {
            let model = coordinator.managedObjectModel
            let name = String(describing: type).components(separatedBy: ".").last!
            return model.entitiesByName[name]
        }
        
        return nil
    }
    
    public func fetch<T: NSManagedObject>(predicate: NSPredicate = .truePredicate, sort: [NSSortDescriptor]? = nil, limit: Int? = nil) -> [T] {
        let request: NSFetchRequest<T> = NSFetchRequest(entityName: T.entityName())
        request.predicate = predicate
        if let limit = limit {
            request.fetchLimit = limit
        }
        request.sortDescriptors = sort
        
        do {
            return try fetch(request)
        } catch {
            print("Fetch \(T.entityName()) failure. Error \(error)")
            return []
        }
    }
    
    func fetchFirstEntity<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate = NSPredicate(format: "TRUEPREDICATE")) -> T? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: type.entityName())
        request.predicate = predicate
        request.fetchLimit = 1
        
        do {
            let result = try fetch(request)
            return result.first as? T
        } catch {
            print(error)
            return nil
        }
    }
    
    @available(iOS 9, tvOS 9, macOS 10.12, *)
    public func fetchedController<T: NSFetchRequestResult>(predicate: NSPredicate? = nil, sort: [NSSortDescriptor], batchSize: Int = 0, sectionNameKeyPath: String? = nil) -> NSFetchedResultsController<T> {
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: T.entityName())
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sort
        fetchRequest.fetchBatchSize = batchSize
        let fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
        do {
            try fetchedController.performFetch()
        } catch {
            print("Fetch error: \(error)")
        }
        
        return fetchedController
    }
    
    public func delete<T: NSManagedObject>(objects: [T]) {
        for d in objects {
            delete(d)
        }
    }
    
    public func fetchAttribute<T: NSManagedObject, Result>(named: String, on entity: T.Type, limit: Int? = nil, predicate: NSPredicate = .truePredicate, distinctResults: Bool = false) -> [Result] {
        let request: NSFetchRequest<NSDictionary> = NSFetchRequest(entityName: T.entityName())
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [named]
        request.returnsDistinctResults = distinctResults
        request.predicate = predicate
        if let limit = limit {
            request.fetchLimit = limit
        }
        
        do {
            let objects = try fetch(request)
            return objects.compactMap { $0[named] as? Result }
        } catch {
            print("fetchEntityAttribute error: \(error)")
            return []
        }
    }
}

