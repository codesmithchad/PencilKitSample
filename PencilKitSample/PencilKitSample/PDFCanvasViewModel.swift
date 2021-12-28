//
//  PDFCanvasViewModel.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2021/12/28.
//

import UIKit
import PencilKit

struct Rendition {
    let title: String
    let image: UIImage
    let drawing: PKDrawing
}

final class PDFCanvasViewModel {
    
    let pdfViewer = PDFViewer()
    let canvasView = PKCanvasView().then {
        $0.tool = PKInkingTool(.pen, color: .gray, width: 20)
//        #if targetEnvironment(simulator)
        $0.drawingPolicy = .anyInput
//        #else
//        $0.drawingPolicy = .pencilOnly
//        #endif
//        $0.backgroundColor = .clear
        $0.isOpaque = false
        $0.isScrollEnabled = true
        $0.minimumZoomScale = 0.5
//        $0.zoomScale = 1
        $0.maximumZoomScale = 2
//        $0.clipsToBounds = false
        $0.debugBounds(.blue, 2)
    }
    private let toolPicker = PKToolPicker()
    private var saveCanvasCompletion: (() -> Void)? = nil
    
    func saveCanvasToAlbum(_ canvasView: PKCanvasView, _ completion: @escaping () -> Void) {
        saveCanvasCompletion = completion
//        let image = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
//        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompletion), nil)
        
        // TODO: remove below
        saveCompletion()
    }
    @objc private func saveCompletion() {
        saveCanvasCompletion?()
    }
    
    func showToolPicker(_ targetView: PKCanvasView) {
        toolPicker.setVisible(true, forFirstResponder: targetView)
        toolPicker.addObserver(targetView)
        targetView.becomeFirstResponder()
    }
}
