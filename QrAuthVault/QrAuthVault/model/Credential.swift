//
//  Credential.swift
//  QrAuthVault
//
//  Created by Valeriy Chevtaev on 15/12/2015.
//  Copyright © 2015 Valera Chevtaev. All rights reserved.
//

import Foundation
import CoreData


class Credential: NSManagedObject {

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    func save() {
        do {
            guard let moc = self.managedObjectContext else {
                throw NSError(domain: "Empty MOC", code: 1, userInfo: nil)
            }
            try moc.save()
        } catch let error as NSError {
            print("ERROR Could not save credentials: \(error), \(error.userInfo)")
        }
    }
}
