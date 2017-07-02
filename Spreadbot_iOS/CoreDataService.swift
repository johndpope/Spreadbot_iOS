//
//  CoreDataService.swift
//  Spreadbot_iOS
//
//  Created by Bob on 02/07/2017.
//  Copyright © 2017 Spreadbot. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataService {
    
    private let entityName = "LocalRequests"
    
    init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext)!
    }
    
    static func getLastRequestPayloadForPath(path: String) -> NSData? {
        guard let requestObject = getLastRequestObjectForPath(path) else {
            return nil
        }
        
        let data = requestObject.valueForKey(Keys.payload) as? NSData
        
        guard data != nil else {
            print("Could not parse data. \(error), \(error.userInfo)")
            return nil
        }
        
        return data
    }
    
    static func saveRequestForPath(path: String, payload: NSData) {
        let uuid = UUID().uuidString
        
        if let requestObject = getLastRequestObjectForPath(path) {
            requestObject.setValue(
                payload, forKeyPath: "payload"
            )
        } else {
            let request = NSManagedObject(entity: entityName, insertInto: managedContext)
            request.setValue(
                path, forKeyPath: "path",
                payload, forKeyPath: "payload",
                uuid, forKeyPath: "uuid"
            )
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save entity. \(error), \(error.userInfo)")
        }
    }
    
    static func deleteReqest(withPath: String) {
        let request = NSFetchRequest(entityName: Keys.entityName)
        
        do {
            let searchResults = try managedContext.fetch(request)
            for requestObject in searchResults {
                if requestObject.path == withPath {
                    managedContext.delete(requestObject)
                }
            }
        } catch let error as NSError {
            print("Error with request: \(error)")
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not delete entity. \(error), \(error.userInfo)")
        }
    }
    
    // private
    
    private func getLastRequestObjectForPath(path: String) -> NSManagedObject? {
        let request = NSFetchRequest(entityName: Keys.entityName)
            .predicate = NSPredicate(format: "path == %@", path)
        
        do {
            if let results = try managedContext.executeFetchRequest(request) {
                return results.isEmpty ? nil : results[0]
            } else {
                return nil
            }
        } catch let error {
            print("Error retrieving current entity: \(error)")
            return nil
        }
    }
    
}
