//
//  ScribbleViewModel.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2022/01/19.
//

import Foundation
import PDFKit
import RxSwift
import CoreData

struct Annotation {
    let title: String
    let pageNo: Int
    let scribbleType: CoreDataController.ScribbleType
    let annotation: [PDFAnnotation]?
}

final class ScribbleViewModel {
    
    private let valotilableWritingKey = "ValotilableWritingKey"
    private var annotations = [Annotation]()
    private let disposeBag = DisposeBag()
    private let valotileObserver = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    private let coreDataController = CoreDataController()
    
    init() {
        coreDataController.fetch()
        retreiveValotilableWriting()
        setupRx()
        fetchAnnotations()
    }
    
    private func setupRx() {
//        valotileObserver.bind(onNext: checkValotileClosure).disposed(by: disposeBag)
    }
    
    private lazy var checkValotileClosure: (Int) -> Void = { [weak self] _ in
        print(#function)
    }
    
    func addAnnotation(_ annotation: Annotation) {
        guard annotation.annotation != nil else { return }
        annotations.append(annotation)
//        saveValotilableWriting(annotation)
//        print("annotations!! \(annotations)")
    }

    func getAnnotaions(_ row: Int) -> Annotation {
        return annotations[row]
    }
    
    var allAnnotations: [Annotation] {
        annotations
    }
    
    func getCurrentAnnotations(_ pageNo: Int) -> [Annotation] {
        annotations.filter({ $0.pageNo == pageNo })
    }
    
    private func saveValotilableWriting(_ annotation: Annotation) {
        guard let writing = annotation.annotation else { return }
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: writing, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: valotilableWritingKey)
        } catch let error {
            print("archive error : \(error.localizedDescription)")
        }
    }
    
    private func retreiveValotilableWriting() {
        print("start retreive")
        guard let data = UserDefaults.standard.object(forKey: valotilableWritingKey) as? Data else { return }
        do {
            if let writing = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [PDFAnnotation] {
                addAnnotation(Annotation(title: "saved annotation", pageNo: 1, scribbleType: .note, annotation: writing))
            }
        } catch let error {
            print("retreive error : \(error.localizedDescription)")
        }
    }
}

extension ScribbleViewModel {
    func saveAnnotation(_ annotation: Annotation) {
        guard let writing = annotation.annotation,
              let data = try? NSKeyedArchiver.archivedData(withRootObject: writing, requiringSecureCoding: false) else { return }
        let writingModel = CoreDataController.WritingModel(title: annotation.title,
                                                           pageNo: annotation.pageNo,
                                                           scribbleType: annotation.scribbleType,
                                                           scribble: data)
        coreDataController.save(writingModel) { [weak self] in
            self?.coreDataController.fetch()
        }
    }

    @discardableResult
    func fetchAnnotations(_ currentPageNo: Int? = nil) -> [NSManagedObject] {
        coreDataController.fetch(currentPageNo)
    }

    func fetchCorrentAnnotation(_ row: Int) -> [Annotation] {
        guard let data = coreDataController.fetch(row).map({ $0.value(forKey: "scribble") }) as? Data else { return [] }
        let jjj = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [PDFAnnotation]
        return []
    }
}


