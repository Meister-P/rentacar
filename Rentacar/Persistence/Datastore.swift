//
//  Datastore.swift
//
//  Datastore wraps a Core Data stack and allows interaction via NSManagedObjectContexts
//  Rentacar
//
//  Created by Mikk Pavelson on 14/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import Foundation
import CoreData

public enum DataStoreError: Int {
    case invalidModel = 0
    case invalidPersistentStore = 1
}

fileprivate let RentacarBundle = Bundle(for: DataStore.self)

internal extension Bundle {
    class func rentacarBundle() -> Bundle? {
        if let url = RentacarBundle.url(forResource: "Rentacar", withExtension: "bundle") {
            return Bundle(url: url)
        }
        
        return nil
    }
}

final public class DataStore: NSObject {
    static let sharedInstance = DataStore(nil)!
    
    struct StackConfig {
        var storeType: String!
        var storeURL: URL!
        var options: [AnyHashable: Any]?
    }
    
    // MARK: Properties
    
    // Store name and file name are constants
    let storeName = "Rentacar"
    let storeFilename = "Rentacar.sqlite"
    
    // Context name, might be used in logging
    let mainContextName = "Main"
    public fileprivate(set) var context: NSManagedObjectContext!
    fileprivate var model: NSManagedObjectModel!
    fileprivate var persistentStoreCoordinator: NSPersistentStoreCoordinator!
    private let storeType: String
    
    // MARK: Public functions
    
    internal init?(storeType: String = NSSQLiteStoreType, _ error: NSErrorPointer) {
        self.storeType = storeType
        
        super.init()        
        
        // Observe context saves, so that migration can work
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSManagedObjectContextDidSave, object: nil, queue: nil) { (notification) -> Void in
            if let context = notification.object as? NSManagedObjectContext, context.persistentStoreCoordinator == self.persistentStoreCoordinator {
                context.performAndWait {
                    context.mergeChanges(fromContextDidSave: notification)
                }
            }
        }
        
        let (success, err) = initialize()
        
        if !success {
            if error != nil && err != nil {
                error?.pointee = err
            }
            
            return nil
        }
        
        let cars = fetchAllEntitiesOfType(Car.self)
        if cars.count == 0 {
            createCars()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    fileprivate func initialize() -> (Bool, NSError?) {
        // Search for the MOMD with our storeName
        let bundles: [Bundle?] = [Bundle(for: DataStore.self), Bundle.rentacarBundle(), Bundle.main]
        var modelURL: URL? = nil
        
        for bundle in bundles {
            if let bundle = bundle, let URL = bundle.url(forResource: storeName, withExtension: "momd") {
                modelURL = URL
                break
            }
        }
        
        if let URL = modelURL, let managedObjectModel = NSManagedObjectModel(contentsOf: URL) { 
            // Keep the model around (so we can query it for entitites without a context around)
            model = managedObjectModel
            
            persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
            context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.name = mainContextName
            context.persistentStoreCoordinator = persistentStoreCoordinator
            
            initializePersistentStore(persistentStoreCoordinator)
            
            return (true, nil)
        } else {
            let dict: RegularDicitionary = [:]
            
            return (false, NSError(domain: RentacarErrorDomain, code: DataStoreError.invalidModel.rawValue, userInfo: dict))
        }
    }
    
    @discardableResult fileprivate func initializePersistentStore(_ coordinator: NSPersistentStoreCoordinator) -> (success: Bool, error: NSError?) {
        // Local DB location
        let url: URL = {
            var url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).last!
            url = url.appendingPathComponent(storeFilename)
            return url
        }()
        
        var options = [AnyHashable: Any]()
        options[NSPersistentStoreFileProtectionKey] = FileProtectionType.complete
        options[NSMigratePersistentStoresAutomaticallyOption] = true
        options[NSInferMappingModelAutomaticallyOption] = true
        
        let config = StackConfig(storeType: storeType, storeURL: url, options: options)
        
        if !addPersistentStore(coordinator, config: config, abortOnFailure: false) {
            try! FileManager.default.removeItem(at: url)
            addPersistentStore(coordinator, config: config, abortOnFailure: true)
        }
        
        return (true, nil)
    }
    
    @discardableResult fileprivate func addPersistentStore(_ coordinator: NSPersistentStoreCoordinator, config: StackConfig, abortOnFailure: Bool) -> Bool {
        do {
            try coordinator.addPersistentStore(ofType: config.storeType, configurationName: nil, at: config.storeURL, options: config.options)
            return true
        } catch {
            let failureReason = "There was an error creating or loading the application's saved data."
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: RentacarErrorDomain, code: DataStoreError.invalidPersistentStore.rawValue, userInfo: dict)
            print("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
        }
        
        if abortOnFailure {
            abort()
        }
        
        return false
    }
    
    internal func entityForName(_ name: String) -> NSEntityDescription? {
        return model.entitiesByName[name]
    }
    
    internal func entityForType<T>(_ type: T.Type) -> NSEntityDescription? {
        let name = String(describing: type).components(separatedBy: ".").last!
        return entityForName(name)
    }
    
    public func save() {
        if !context.hasChanges {
            return
        }
        
        context.performAndWait() {
            do {
                try self.context.self.save()
            } catch let error as NSError {
                print("Failed to save the main context \(error)")
            }
        }
    }
    
    ///
    /// Deleting the entire database, useful for logout etc
    ///
    public func deleteAllData() -> Void {
        for persistentStore in persistentStoreCoordinator.persistentStores {
            if let url = persistentStore.url {
                do {
                    try persistentStoreCoordinator.remove(persistentStore)
                } catch _ {
                }
                do {
                    try FileManager.default.removeItem(atPath: url.path)
                } catch _ {}
            }
        }
        
        initializePersistentStore(persistentStoreCoordinator)
        
        // Reset the context (so that any in-memory object is "forgotten")
        context.reset()
    }
    
    func createFetchedControllerForEntity<T: NSManagedObject>(_ entity: T.Type, predicate: NSPredicate = NSPredicate(format: "TRUEPREDICATE"), sortDesciptors: [NSSortDescriptor], sectionKeyPath: String? = nil) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = fetchRequestForEntity(entity, predicate: predicate, sortDescriptors: sortDesciptors)
        let fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionKeyPath, cacheName: nil)
        
        do {
            try fetchedController.performFetch()
        } catch {
            print("Fetch error: \(error)")
        }
        
        return fetchedController
    }
    
    func fetchRequestForEntity<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate, sortDescriptors: [NSSortDescriptor] = []) -> NSFetchRequest<NSFetchRequestResult> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: type.entityName())
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        return request
    }
    
    public func fetchAllEntitiesOfType<T: NSManagedObject>(_ type: T.Type, usingPredicate predicate: NSPredicate = NSPredicate(format: "TRUEPREDICATE")) -> [T] {
        let request = fetchRequestForEntity(type, predicate: predicate)
        
        do {
            let result = try context.fetch(request)
            return result as! [T]
        } catch {
            print(error)
            return []
        }
    }
    
    func deleteAllInstancesOfEntity<T: NSManagedObject>(_ entity: T.Type, usingPredicate predicate: NSPredicate = NSPredicate(format: "TRUEPREDICATE")) {
        let toDelete = fetchAllEntitiesOfType(entity, usingPredicate: predicate)
        if toDelete.count == 0 {
            return
        }
        
        for deleted in toDelete {
            context.delete(deleted)
        }
    }
    
    func addObject<T: NSManagedObject>(_ type: T.Type) -> T {
        let entity = entityForType(type)!
        return T(entity: entity, insertInto: context)
    }
    
    func deleteObject(_ object: NSManagedObject) {
        context.delete(object)
    }
    
   func fetchFirstEntity<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate = NSPredicate(format: "TRUEPREDICATE"), sortDescriptors: [NSSortDescriptor] = []) -> T? {
        let request = fetchRequestForEntity(type, predicate: predicate, sortDescriptors: sortDescriptors)
        request.fetchLimit = 1
        
        do {
            let result = try context.fetch(request)
            return result.first as? T
        } catch {
            print(error)
            return nil
        }
    }
}

extension DataStore {
    var allUsers: [User] {
        let users = fetchAllEntitiesOfType(User.self)
        return users
    }
    
    @discardableResult
    func createNewUserWith(firstName: String, lastName: String, email: String, password: String) -> User {
        let newUser = addObject(User.self)
        newUser.firstName = firstName
        newUser.lastname = lastName
        newUser.email = email
        newUser.password = password
        
        newUser.session = newSession()
        
        save()
        
        return newUser
    }
    
    @discardableResult
    func newSession() -> Session {
        let newSession = addObject(Session.self)
        newSession.startDate = Date() as NSDate
        newSession.endDate = Date().dateInNumberOfMinutes(UserSessionMinutes) as NSDate
        
        return newSession
    }
    
    func createCars() {
        let carsFile = Bundle.main.path(forResource: "Cars", ofType: "plist")!
        let cars = NSDictionary(contentsOfFile: carsFile) as! [String: [String: [String: AnyObject]]]
        
        if let carsDict = cars["cars"] {
            for carDictKey in carsDict.keys {
                if let car = carsDict[carDictKey] {
                    let newCar = addObject(Car.self)
                    newCar.imageUrl = car["imageUrl"] as? String
                    newCar.thumbnailUrl = car["thumbnailUrl"] as? String
                    newCar.mark = car["mark"] as? String
                    newCar.model = car["model"] as? String
                    newCar.priceDay = NSDecimalNumber(decimal: (car["priceDay"] as! NSNumber).decimalValue)
                }
            }
        }
        
        save()
    }
}

