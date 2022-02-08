//
//  CoreDataController.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2022/02/07.
//

import Foundation
import CoreData

final class CoreDataController {
    
    private let containerName = "ScribbleModel"
    private let entityName = "Writing"
    
    enum ScribbleType: Int {
        case note, valotile
    }
    
    struct WritingModel {
        var createdAt: Date
        var scribble: Data?
        var scribbleType: ScribbleType?
        var title: String?
        
        init(createdAt: Date = Date(), scribble: Data? = nil, scribbleType: ScribbleType = .note, title: String? = nil) {
            self.createdAt = createdAt
            self.scribble = scribble
            self.scribbleType = scribbleType
            self.title = title
        }
    }
    
    var writings: [NSManagedObject] = []
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func save(_ writingModel: WritingModel, completion: @escaping () -> Void) {
        let context = persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return }
        let wiring = NSManagedObject(entity: entity, insertInto: context)
        wiring.setValue(writingModel.createdAt, forKey: "createdAt")
        wiring.setValue(writingModel.scribble, forKey: "scribble")
        wiring.setValue(0, forKey: "scribbleType")
        wiring.setValue(writingModel.title, forKey: "title")

        guard context.hasChanges else { return }

        do {
            try context.save()
            completion()
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func fetch() {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
//        fetchRequest.predicate = NSPredicate(format: "scribbleType = %d", 0)
        do {
            writings = try context.fetch(fetchRequest)
            
//            let wringg = writings.map({
//                return WritingModel(createdAt: $0.value(forKey: "createdAt") as? Date ?? Date(),
//                                    scribble: $0.value(forKey: "scribble") as? Data,
//                                    scribbleType: $0.value(forKey: "scribbleType") as? Int ?? 0,
//                                    title: $0.value(forKey: "title") as? String)
//            })
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
