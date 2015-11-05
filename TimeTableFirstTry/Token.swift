//
//  Token.swift
//  TimeTableFirstTry
//
//  Created by Lukas Boner on 05.11.15.
//  Copyright © 2015 Aurel Feer. All rights reserved.
//

import Foundation
import CoreData

class Token: NSManagedObject {
    
    @NSManaged var tokenVar: String!
    
    class func createInManagedObjectContext(moc: NSManagedObjectContext, tokenVar: String) -> Token {
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Token", inManagedObjectContext: moc) as! Token
        newItem.tokenVar = tokenVar
        
        return newItem
    }
    
}
