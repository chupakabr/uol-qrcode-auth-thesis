//
//  Credential+CoreDataProperties.swift
//  QrAuthVault
//
//  Created by Valeriy Chevtaev on 15/12/2015.
//  Copyright © 2015 Valera Chevtaev. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Credential {

    @NSManaged var usr: String?
    @NSManaged var pwd: String?
    @NSManaged var service: String?

}
