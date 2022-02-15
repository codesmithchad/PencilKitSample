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

final class ScribbleViewModel {
    
    private var annotations = [Annotation]()
    private let disposeBag = DisposeBag()
    
    init() {
        setupRx()
    }
    
    private func setupRx() {
//        valotileObserver.bind(onNext: checkValotileClosure).disposed(by: disposeBag)
    }
    
    /*
    private lazy var checkValotileClosure: (Int) -> Void = { [weak self] _ in
        print(#function)
    }
    
    var allAnnotations: [Annotation] {
        annotations
    }
    */
    
    @discardableResult
    func fetchAnnotations(_ pageNo: Int?) -> [Annotation] {
        let fetches: [NSManagedObject] = PersistenceManager.shared.fetch()
        let annotaions: [Annotation] = fetches.map { managedObject in
            var scribbles: [PDFAnnotation]? = nil
            if let data = managedObject.value(forKey: "annotation") as? Data {
                scribbles = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [PDFAnnotation]
            }
            return Annotation(title: managedObject.value(forKey: "title") as? String ?? "",
                              pageNo: managedObject.value(forKey: "pageNo") as? Int ?? 0,
                              scribbleType: (managedObject.value(forKey: "scribbleType") as? ScribbleType ?? .note),
                              annotation: scribbles)
        }
        return annotaions
    }
    
    func insertAnnotation(_ annotation: Annotation) {
        guard let writing = annotation.annotation,
              let data = try? NSKeyedArchiver.archivedData(withRootObject: writing, requiringSecureCoding: false) else { return }
        
        let annotaionToSave = AnnotationToSave(title: annotation.title,
                                               pageNo: annotation.pageNo,
                                               scribbleType: annotation.scribbleType.rawValue,
                                               annotation: data)
        PersistenceManager.shared.insert(elements: annotaionToSave)
    }
}
