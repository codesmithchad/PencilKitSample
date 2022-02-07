//
//  PlayGroundViewController.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2021/12/27.
//

import UIKit
import RxSwift
import PDFKit

class PlayGroundViewController: UIViewController {

    private let disposeBag = DisposeBag()
    private let pdfViewer = PDFView() //PDFViewer()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
    }
    
    private func setupUI() {
        title = self.className
        view.addSubviews(pdfViewer)
        pdfViewer.debugBounds()
        pdfViewer.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupRx() {
//        guard let currentPage = pdfViewer.currentPage else { return }
//        pdfViewer.draw(currentPage)
//        guard let currentPage = PDFViewer().currentPage else { return }
        
        
        drawOnPDF(path: PDFViewer.samplePdfUrl, signatureImage: UIImage())
    }
    
    func drawOnPDF(path: String , signatureImage: UIImage) {
            
        // Get existing Pdf reference
//        guard let pdf = CGPDFDocument(NSURL(fileURLWithPath: path)) else {
//            print("there's no pdf file in \(path)")
//            return
//        }
        
//        guard let pdfUrl = URL(string: path),
//              let pdf = PDFDocument(url: pdfUrl) else { return }
//
//        // Get page count of pdf, so we can loop through pages and draw them accordingly
//        let pageCount = pdf.numberOfPages
//
//
//        // Write to file
//        UIGraphicsBeginPDFContextToFile(path, CGRect.zero, nil)
//
//        // Write to data
//        //var data = NSMutableData()
//        //UIGraphicsBeginPDFContextToData(data, CGRectZero, nil)
//
//        for index in 1...pageCount {
//            guard let page = pdf.page(at: index) else {
//                print("no page at \(index)")
//                return
//            }
//
//            let pageFrame = page.getBoxRect(.mediaBox)
//
//            UIGraphicsBeginPDFPageWithInfo(pageFrame, nil)
//
//            let ctx = UIGraphicsGetCurrentContext()
//
//            // Draw existing page
//            ctx!.saveGState()
//
//            ctx!.scaleBy(x: 1, y: -1)
//
//            ctx!.translateBy(x: 0, y: -pageFrame.size.height)
//            //CGContextTranslateCTM(ctx, 0, -pageFrame.size.height);
//            ctx!.drawPDFPage(page)
//            ctx!.restoreGState()
//
//            // Draw image on top of page
//            let image = signatureImage
//            image.draw(in: CGRect(x: 100, y: 100, width: 100, height: 100))
//            // Draw red box on top of page
//            //UIColor.redColor().set()
//            //UIRectFill(CGRectMake(20, 20, 100, 100));
//        }
//
//        UIGraphicsEndPDFContext()
    }
}
