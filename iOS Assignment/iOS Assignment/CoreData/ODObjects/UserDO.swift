//
//  UserDO.swift
//  iOS Assignment
//
//  Created by Dai on 15/09/2020.
//  Copyright © 2020 Dai. All rights reserved.
//

import Foundation
import CoreData

extension UserDO {
    @NSManaged public var jsonString,email: String?
}

@objc(UserDO)
open class UserDO: NSManagedObject {

    //MARK: - Initialize
    convenience init(context: NSManagedObjectContext?) {
        
        // Create the NSEntityDescription
        let entity = NSEntityDescription.entity(forEntityName: "UserDO", in: context!)
        
        self.init(entity: entity!, insertInto: context)
    }
    
    @nonobjc public class func fetchRequestD() -> NSFetchRequest<UserDO> {
        let fetch = NSFetchRequest<UserDO>(entityName: "UserDO")
        fetch.returnsObjectsAsFaults = false
        fetch.shouldRefreshRefetchedObjects = true
        return fetch
    }
    
    /// save user to local
    /// - Parameters:
    ///   - user: user object
    ///   - complete: complete with error
    static func save(user:User,
                     _ complete:((Any?)->Void)?) {
        let container = CoreDataStack.sharedInstance.managedObjectContext
        let group = DispatchGroup()
        group.enter()
        clearData(email:user.email) {error in
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main) {
            container.perform {
                if let object = NSEntityDescription.insertNewObject(forEntityName: "UserDO", into: container) as? UserDO {
                    object.jsonString = try? user.jsonString()
                    object.email = user.email
                }
                
                do {
                    try container.save()
                    complete?(nil)
                } catch let err {
                    #if DEBUG
                    print("\(#function) \(err.localizedDescription) ")
                    #endif
                    complete?(err.localizedDescription)
                }
            }
        }
    }
    
    /// get all favourite users
    /// - Parameter complete: complete with list users
    static public func getFavouriteUsers(_ complete:(([User])->Void)?) {
        
        let context = CoreDataStack.sharedInstance.managedObjectContext
        context.perform {
            let fetchRequest = UserDO.fetchRequestD()
            do {
                let listConsults = try context.fetch(fetchRequest)
                complete?(listConsults.compactMap({ (ccDO) -> User? in
                    return try? User.init(ccDO.jsonString ?? "", using: .utf8)
                }))
            } catch {
                complete?([])
                return
            }
        }
    }
    
    /// clear all same records
    /// - Parameters:
    ///   - email: user email
    ///   - complete: complete
    static func clearData(email:String?,
                          _ complete:((Any?)->Void)?) {
        guard let email = email else {
            complete?(nil)
            return
        }
        do {
            let context = CoreDataStack.sharedInstance.managedObjectContext
            let fetchRequest = UserDO.fetchRequestD()
            fetchRequest.predicate = NSPredicate(format: "email IN %@",[email])
            do {
                _ = try context.fetch(fetchRequest).map({context.delete($0)})
                complete?(nil)
            } catch let error {
                complete?(error.localizedDescription)
            }
        }
    }
}
