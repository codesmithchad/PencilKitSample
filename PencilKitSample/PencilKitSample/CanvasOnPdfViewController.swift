//
//  CanvasOnPdfViewController.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2021/12/30.
//

import UIKit
import SnapKit
import PencilKit
import PDFKit

final class CanvasOnPdfViewController: UIViewController {
    
    private lazy var pdfViewer = PDFViewer()
    private let canvasView = PKCanvasView().then {
        $0.isOpaque = false
        $0.tool = PKInkingTool(.pen, color: .red, width: 20)
        $0.drawingPolicy = .anyInput //.pencilOnly
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBlue
        title = className
        
        view.addSubviews(canvasView, pdfViewer)
        canvasView.layer.frame = UIScreen.main.bounds
        pdfViewer.layer.addSublayer(canvasView.layer)
        pdfViewer.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
//        canvasView.snp.makeConstraints {
//            $0.size.equalTo(CGSize(width: UIScreen.width/2, height: UIScreen.height/2))
//            $0.center.equalTo(view.safeAreaLayoutGuide)
//        }
        
        canvasView.debugBounds(.blue, 4 )
        
//        NotificationCenter.default.addObserver(self, selector: #selector(zooomeed(_:)), name: .PDFViewScaleChanged, object: nil)
    }
//    @objc private func zooomeed(_ notification: Notification) { }
}

extension CanvasOnPdfViewController: PDFViewDelegate {
    
//    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        canvasView.frame = CGRect(origin: scrollView.contentOffset, size: scrollView.contentSize)
//    }
}

extension CanvasOnPdfViewController {
    private func inspecting() {
        pdfViewer.subviews.first?.subviews.forEach({ view in
            print("[??] \(type(of: view))")
        })
        print("=====1=====")
        dump(pdfViewer.subviews)
        print("=====2=====")
        dump(pdfViewer.subviews.first?.subviews)
        print("=====3=====")
        dump(pdfViewer.subviews.first?.subviews.first?.subviews)
        pdfViewer.subviews.first?.subviews.first?.subviews.enumerated().forEach({
            let color = [UIColor.red, UIColor.green, UIColor.blue][$0.offset%3]
            $0.element.debugBounds(color, 3)
            //            print(type(of: $0.element))
        })
        
        let filt = pdfViewer.subviews.first?.subviews.first?.subviews.filter({ $0.isKind(of: UIView.self) })
        print(filt?.count ?? 0)
        
//        let ssmp = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
//        ssmp.backgroundColor = .red
//        pdfViewer.subviews.first?.subviews.first?.subviews.first?.addSubview(ssmp)
        print("=====4=====")
//        dump(pdfViewer)

//        pdfViewer.subviews.first?.subviews.first?.subviews.first?.debugBounds()
    }
}
