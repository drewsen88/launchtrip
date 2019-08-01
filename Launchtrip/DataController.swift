//
//  DataController.swift
//  Launchtrip
//
//  Created by Drew Sen on 2019-07-30.
//  Copyright © 2019 Drew Sen. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer = NSPersistentContainer(name: "LTUserDataModel")
    
    func initializeStack() {
        
        self.persistentContainer.loadPersistentStores(completionHandler: { description, error in
            // 3.
            if let error = error {
                print("could not load store \(error.localizedDescription)")
                return
            }
            
            print("store loaded")
        })
        
    }
}
