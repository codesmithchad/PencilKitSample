//
//  ScribbleViewModel.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2022/01/19.
//

import Foundation
import PDFKit
import RxSwift

struct Annotation {
    let title: String
    let pageNo: Int
    let annotation: [PDFAnnotation]?
}

final class ScribbleViewModel {
    
    private let valotilableWritingKey = "ValotilableWritingKey"
    private var annotations = [Annotation]()
    private let disposeBag = DisposeBag()
    private let valotileObserver = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
    
    init() {
        retreiveValotilableWriting()
        setupRx()
    }
    
    private func setupRx() {
        valotileObserver.bind(onNext: checkValotileClosure).disposed(by: disposeBag)
    }
    
    private lazy var checkValotileClosure: (Int) -> Void = { [weak self] _ in
        print(#function)
    }
    
    func addAnnotation(_ annotation: Annotation) {
        guard annotation.annotation != nil else { return }
        annotations.append(annotation)
//        saveValotilableWriting(annotation)
        print("annotations!! \(annotations)")
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
                addAnnotation(Annotation(title: "saved annotation", pageNo: 1, annotation: writing))
            }
        } catch let error {
            print("retreive error : \(error.localizedDescription)")
        }
    }
}


