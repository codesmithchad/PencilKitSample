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
import RxSwift

final class CanvasOnPdfViewController: UIViewController {
    
    private let disposeBag = DisposeBag()
    private lazy var pdfViewer = PDFViewer()
    private let canvasView = PKCanvasView().then {
        $0.isOpaque = false
        $0.tool = PKInkingTool(.pen, color: .red, width: 20)
        $0.drawingPolicy = .anyInput //.pencilOnly
    }
    private let toolPicker = PKToolPicker()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .green
        title = className
        
        view.addSubviews(canvasView, pdfViewer)
//        canvasView.layer.frame = pdfViewer.bounds
        pdfViewer.layer.addSublayer(canvasView.layer)
        pdfViewer.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        canvasView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
        togglePicker()
        
//        canvasView.snp.makeConstraints {
//            $0.size.equalTo(CGSize(width: UIScreen.width/2, height: UIScreen.height/2))
//            $0.center.equalTo(view.safeAreaLayoutGuide)
//        }
        
        pdfViewer.debugBounds(.magenta, 2)
        canvasView.debugBounds(.blue, 6)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(zooomeed(_:)), name: .PDFViewScaleChanged, object: nil)
    }
//    @objc private func zooomeed(_ notification: Notification) { }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        canvasView.layer.frame = pdfViewer.bounds
    }
    
    private func togglePicker() {
        let button = UIButton(type: .contactAdd)
        button.rx.controlEvent(.touchUpInside)
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                let showPciker = self.toolPicker.isVisible
                self.toolPicker.setVisible(!showPciker, forFirstResponder: self.canvasView)
            })
            .disposed(by: disposeBag)
        navigationItem.setRightBarButton(UIBarButtonItem(customView: button), animated: true)
    }
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




class PDFDrawingGestureRecognizer: UIGestureRecognizer {
    weak var pdfView: PDFView!
    private var lastPoint = CGPoint()
    private var currentAnnotation : PDFAnnotation?
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first,
           let numberOfTouches = event?.allTouches?.count,
           numberOfTouches == 1 {
            state = .began
            
            let position = touch.location(in: pdfView)
            let convertedPoint = pdfView.convert(position, to: pdfView.currentPage!)
            
            lastPoint = convertedPoint
        } else {
            state = .failed
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .changed
        
        guard let position = touches.first?.location(in: pdfView) else { return }
        let convertedPoint = pdfView.convert(position, to: pdfView.currentPage!)
        
        let path = UIBezierPath()
        path.move(to: lastPoint)
        path.addLine(to: convertedPoint)
        lastPoint = convertedPoint
        
        if currentAnnotation == nil {
            let border = PDFBorder()
            border.lineWidth = 10
            border.style = .solid
            
            currentAnnotation = PDFAnnotation(bounds: pdfView.bounds, forType: .ink, withProperties: [
                PDFAnnotationKey.border: border,
                PDFAnnotationKey.color: UIColor.red,
                PDFAnnotationKey.interiorColor: UIColor.red,
            ])
            let pageIndex = pdfView.document!.index(for: pdfView.currentPage!)
            pdfView.document?.page(at: pageIndex)?.addAnnotation(currentAnnotation!)
        }
        currentAnnotation!.add(path)
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let position = touches.first?.location(in: pdfView) else {
            state = .ended
            return
        }
        
        let convertedPoint = pdfView.convert(position, to: pdfView.currentPage!)
        
        let path = UIBezierPath()
        path.move(to: lastPoint)
        path.addLine(to: convertedPoint)
        
        currentAnnotation?.add(path)
        currentAnnotation = nil
        
        state = .ended
    }
}
