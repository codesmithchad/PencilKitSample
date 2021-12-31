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
    
    init(_ target: PKCanvasViewDelegate) {
        canvasView.delegate = target
        showToolPicker()
    }
    
    let pdfViewer = PDFViewer()
    let canvasView = PKCanvasView().then {
        $0.tool = PKInkingTool(.pen, color: .gray, width: 20)
//        #if targetEnvironment(simulator)
//        $0.drawingPolicy = .pencilOnly
//        #else
//        $0.drawingPolicy = .pencilOnly
//        #endif
        $0.isOpaque = false
        $0.isScrollEnabled = true
//        $0.minimumZoomScale = 0.5
        $0.maximumZoomScale = 2
    }
    
    private let toolPicker = PKToolPicker()
    private var saveCanvasCompletion: (() -> Void)? = nil
    
    func saveCanvasToAlbum(_ completion: @escaping () -> Void) {
        saveCanvasCompletion = completion
        // TODO: must unblocked below and remove saveCompletion()
//        let image = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
//        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompletion), nil)
        saveCompletion()
    }
    @objc private func saveCompletion() {
        saveCanvasCompletion?()
    }
    
    private func showToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
    
    func setDelegate(_ target: PKCanvasViewDelegate) {
        canvasView.delegate = target
    }
    
    func addPdfViewerOnCanvas() {
        canvasView.subviews.first?.insertSubview(pdfViewer, at: 0)
    }
    
    func setPdfViewerZoomScale(_ zoomScale: CGFloat) {
        pdfViewer.setZoomScale(zoomScale)
    }
    
    func getPdfSize() -> CGSize {
        print(pdfViewer.currentPage?.bounds(for: .mediaBox).size)
        return pdfViewer.currentPage?.bounds(for: .mediaBox).size ?? .zero
    }
}
