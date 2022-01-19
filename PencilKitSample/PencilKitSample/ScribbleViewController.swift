//
//  ScribbleViewController.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2022/01/03.
//

import UIKit
import PDFKit
import RxSwift
import RxCocoa
import Then

final class Dummies {
    static var pdfDocument: PDFDocument? {
        guard let url = Bundle.main.url(forResource: "sample_science", withExtension: "pdf") else { return nil }
        return PDFDocument(url: url)
    }
}

final class ScribbleViewController: UIViewController {

    private let disposeBag = DisposeBag()
    private var shouldUpdatePDFScrollPosition = true
    private let pdfDrawer = PDFDrawer()
    private var pdfView = PDFView().then {
        $0.document = Dummies.pdfDocument
        $0.displayDirection = .horizontal
        $0.usePageViewController(true)
        $0.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.autoScales = true
    }
//    @IBOutlet weak var pdfView: PDFView!
//    @IBOutlet weak var thumbnailView: PDFThumbnailView!
//    @IBOutlet weak var thumbnailViewContainer: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        title = className
        view.backgroundColor = .systemBrown
        view.addSubviews(pdfView)
        pdfView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        setupPDFView()
        setupNavButtons()
    }

    private func setupPDFView() {
        let pdfDrawingGestureRecognizer = DrawingGestureRecognizer()
        pdfView.addGestureRecognizer(pdfDrawingGestureRecognizer)
        pdfDrawingGestureRecognizer.drawingDelegate = pdfDrawer
        pdfDrawer.pdfView = pdfView
//        pdfView.backgroundColor = view.backgroundColor!

//        thumbnailView.pdfView = pdfView
//        thumbnailView.thumbnailSize = CGSize(width: 100, height: 100)
//        thumbnailView.layoutMode = .vertical
//        thumbnailView.backgroundColor = thumbnailViewContainer.backgroundColor
    }
    
    private func setupNavButtons() {
        let removeButton = UIButton(type: .system)
        removeButton.setTitle("remove", for: .normal)
        removeButton.rx
            .controlEvent(.touchUpInside)
            .bind(onNext: { [weak self] in
                self?.removeCurrentAnnotation()
            })
            .disposed(by: disposeBag)
        let storeButton = UIButton(type: .system)
        storeButton.setTitle("store", for: .normal)
        storeButton.rx
            .controlEvent(.touchUpInside)
            .bind(onNext: { [weak self] in
                self?.storeAnnotation()
            })
            .disposed(by: disposeBag)
        let restoreButton = UIButton(type: .system)
        restoreButton.setTitle("restore", for: .normal)
        restoreButton.rx
            .controlEvent(.touchUpInside)
            .bind(onNext: { [weak self] in
                self?.restoreAnnotation()
            })
            .disposed(by: disposeBag)
        
        
        navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: storeButton),
                                               UIBarButtonItem(customView: restoreButton),
                                               UIBarButtonItem(customView: removeButton)], animated: true)
    }
    
    private func removeCurrentAnnotation() {
        guard let page = pdfView.document?.page(at: 0) else { return }
        for annotation in page.annotations {
            page.removeAnnotation(annotation)
            page.addAnnotation(PDFAnnotation())
        }
    }
    private var pdfAnnotations: [PDFAnnotation]?
    private func storeAnnotation() {
        pdfAnnotations = pdfView.document?.page(at: 0)?.annotations
        
    }
    private func restoreAnnotation() {
//        pdfView.currentPage?.removeAnnotation(<#T##annotation: PDFAnnotation##PDFAnnotation#>)
        pdfAnnotations?.forEach({ [weak self] annotation in
            self?.pdfView.currentPage?.addAnnotation(annotation)
        })
    }

    // This code is required to fix PDFView Scroll Position when NOT using pdfView.usePageViewController(true)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if shouldUpdatePDFScrollPosition {
            fixPDFViewScrollPosition()
        }
    }

    // This code is required to fix PDFView Scroll Position when NOT using pdfView.usePageViewController(true)
    private func fixPDFViewScrollPosition() {
        if let page = pdfView.document?.page(at: 0) {
            pdfView.go(to: PDFDestination(page: page, at: CGPoint(x: 0, y: page.bounds(for: pdfView.displayBox).size.height)))
        }
    }

    // This code is required to fix PDFView Scroll Position when NOT using pdfView.usePageViewController(true)
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        shouldUpdatePDFScrollPosition = false
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        pdfView.autoScales = true // This call is required to fix PDF document scale, seems to be bug inside PDFKit
    }
    
}
