//
//  Model.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2022/02/15.
//

import Foundation
import PDFKit

// MARK: - Model

enum ScribbleType: Int {
    case note, valotile
}

struct Annotation {
    let title: String
    let pageNo: Int
    let scribbleType: ScribbleType
    let annotation: [PDFAnnotation]?
}

struct AnnotationToSave: Loopable {
    let title: String
    let pageNo: Int
    let scribbleType: Int
    let annotation: Data
}

// MARK: - Persistence manager extension

extension PersistenceManager {
    static var containerName: String = "ScribbleModel"
    static var entityName: String = "Writing"
}
