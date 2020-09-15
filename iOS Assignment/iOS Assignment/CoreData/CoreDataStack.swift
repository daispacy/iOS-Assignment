//
//  CoreDataStack.swift
//  CoreDataTutorialPart1Final
//
//  Created by James Rochabrun on 3/1/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataStack: NSObject {
    
    static let sharedInstance = CoreDataStack()
    var shouldRefresh:(()->Void)?
    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: Notification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    @objc func contextObjectsDidChange(_ notification: Notification) {
        managedObjectContext.perform {
            do {
                if self.managedObjectContext.hasChanges {
                    try self.managedObjectContext.save()
                }
            } catch {
                let saveError = error as NSError
                print("Unable to Save Changes of Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
            }
            
            self.saveManagedObjectContext.perform {
                do {
                    if self.saveManagedObjectContext.hasChanges {
                        try self.saveManagedObjectContext.save()
                        self.shouldRefresh?()
                    }
                } catch {
                    let saveError = error as NSError
                    print("Unable to Save Changes of Private Managed Object Context")
                    print("\(saveError), \(saveError.localizedDescription)")
                }
            }
            
        }
    }
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "assignment")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
//                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    lazy var managedObjectContext:NSManagedObjectContext = {
        let write = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        write.parent = self.saveManagedObjectContext
        
        return write
    }()
    
    lazy var saveManagedObjectContext:NSManagedObjectContext = {
        let coordinator = self.persistentContainer.persistentStoreCoordinator
        let write = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        write.persistentStoreCoordinator = coordinator
        return write
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        
        do {
            try? CoreDataStack.sharedInstance.managedObjectContext.save()
        }
        do {
            try? CoreDataStack.sharedInstance.saveManagedObjectContext.save()
        }
        
        let context = persistentContainer.viewContext
        
//        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
                #if DEBUG
                fatalError("Unresolved error \(error.localizedDescription)")
                #endif
            }
//        }
    }
}



extension CoreDataStack {
    
    func applicationDocumentsDirectory() {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "yo.BlogReaderApp" in the application's documents directory.
        if let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last {
            #if DEBUG
            print("\(#function) \(url.absoluteString.uppercased()) ")
            #endif

            let checkDeletaOldData = UserDefaults.standard.bool(forKey: "App:DeleteOldCoreData")
            if !checkDeletaOldData {
                let storeURL: URL = url.appendingPathComponent("/assignment.sqlite") as URL
                do {
                    try? FileManager.default.removeItem(at: storeURL)
                    UserDefaults.standard.set(true, forKey: "App:DeleteOldCoreData")
                }
            }
        }
    }
}
