//
//  CoreDataController.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2022/02/07.
//
//  more ref: https://zeddios.tistory.com/989

import Foundation
import CoreData

final class CoreDataController {
    
    private let containerName = "ScribbleModel"
    private let entityName = "Writing"
    
    enum ScribbleType: Int {
        case note, valotile
    }
    
    struct WritingModel {
        var title: String?
        var createdAt: Date
        var pageNo: Int
        var scribbleType: ScribbleType?
        var scribble: Data?
        
        init(title: String? = nil, createdAt: Date = Date(), pageNo: Int = 0, scribbleType: ScribbleType = .note, scribble: Data? = nil) {
            self.title = title
            self.createdAt = createdAt
            self.pageNo = pageNo
            self.scribbleType = scribbleType
            self.scribble = scribble
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
    
    private lazy var context = persistentContainer.viewContext
    
    // MARK: - Core Data Saving support
    
    func save(_ writingModel: WritingModel, completion: @escaping () -> Void) {
//        let context = persistentContainer.viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: context) else { return }
        let wiring = NSManagedObject(entity: entity, insertInto: context)
        wiring.setValue(writingModel.title, forKey: "title")
        wiring.setValue(writingModel.createdAt, forKey: "createdAt")
        wiring.setValue(writingModel.pageNo, forKey: "pageNo")
        wiring.setValue(writingModel.scribbleType?.rawValue, forKey: "scribbleType")
        wiring.setValue(writingModel.scribble, forKey: "scribble")

        guard context.hasChanges else { return }

        do {
            try context.save()
            completion()
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
    
    func fetch(_ currentPageNo: Int? = nil) -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        if let pageNo = currentPageNo {
            fetchRequest.predicate = NSPredicate(format: "pageNo = %d", pageNo)
        }

        guard let writings = try? context.fetch(fetchRequest) else {
            return []
        }
        self.writings = writings
        return writings
    }
    
    func delete(_ index: Int) {
        context.delete(writings[index])
        do {
            try context.save()
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
