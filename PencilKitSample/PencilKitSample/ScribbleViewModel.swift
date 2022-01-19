//
//  ScribbleViewModel.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2022/01/19.
//

import Foundation
import PDFKit

struct Annotation {
    let title: String
    let annotation: [PDFAnnotation]?
}

final class ScribbleViewModel {
    
    private var annotations = [Annotation]()
    
    func addAnnotation(_ annotation: Annotation) {
        guard annotation.annotation != nil else { return }
        annotations.append(annotation)
    }

    func getAnnotaions(_ row: Int) -> Annotation {
        return annotations[row]
    }
    
    var allAnnotations: [Annotation] {
        annotations
    }
}


