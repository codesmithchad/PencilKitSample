//
//  PDFViewer.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2021/12/28.
//

import UIKit
import PDFKit

final class PDFViewer: PDFView {

    static let samplePdfUrl = "https://juventudedesporto.cplp.org/files/sample-pdf_9359.pdf"
    static let samplPdfLocal = Bundle.main.path(forResource: "sample-pdf", ofType: "pdf") ?? ""

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
//        displaysPageBreaks = false
        usePageViewController(true, withViewOptions: nil)

        // FIXME: must removed below 2 line and unlock documentated.
        let pdfUrl = URL(fileURLWithPath: Self.samplPdfLocal)
        guard let pdfDocument = PDFDocument(url: pdfUrl) else { return }
//        guard let pdfUrl = URL(string: Self.samplePdfUrl),
//              let pdfDocument = PDFDocument(url: pdfUrl) else { return }
        document = pdfDocument
        backgroundColor = .systemYellow
        pageShadowsEnabled = false
        displaysPageBreaks = false
    }
    
    func setZoomScale(_ scale: CGFloat) {
        scaleFactor = scale
    }
}
