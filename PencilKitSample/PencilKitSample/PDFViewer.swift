//
//  PDFViewer.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2021/12/28.
//

import UIKit
import PDFKit

class PDFViewer: PDFView {

    static let samplePdfUrl = "https://juventudedesporto.cplp.org/files/sample-pdf_9359.pdf"

    init(_ frame: CGRect = .zero) {
        super.init(frame: frame)
        setupPdf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupPdf() {
        displayMode = .singlePageContinuous
        autoScales = true
        displayDirection = .horizontal
//        delegate = self
        displayBox = .cropBox
        usePageViewController(true, withViewOptions: nil)

        guard let pdfUrl = URL(string: Self.samplePdfUrl),
              let pdfDocument = PDFDocument(url: pdfUrl) else { return }
        document = pdfDocument
        backgroundColor = .clear
    }
    
    func setZoomScale(_ scale: CGFloat) {
        scaleFactor = scale
    }
}
