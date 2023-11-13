//
//  Storage.swift
//  oCode
//
//  Created by Kamil Foatov on 12.11.2023.
//

import Foundation
import CoreData

class Storage {
    let context: NSManagedObjectContext
    
    init(_ context: NSManagedObjectContext) {
        self.context = context
    }
    
    func load() -> [ProgramDataModel]? {
        do {
            return try context.fetch(ProgramDataModel.fetchRequest())
        } catch {
            print("couldn't fetch data from CoreData")
        }
        return nil
    }
    
    func newProgram() -> ProgramDataModel {
        ProgramDataModel(context: context)
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("error while saving the CoreData context")
            }
        }
    }
}
