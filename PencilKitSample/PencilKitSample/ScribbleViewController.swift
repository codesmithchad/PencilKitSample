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
    private let viewModel = ScribbleViewModel()
    private var shouldUpdatePDFScrollPosition = true
    private let pdfDrawer = PDFDrawer()
    private var pdfView = PDFView().then {
        $0.document = Dummies.pdfDocument
        $0.displayDirection = .horizontal
        $0.usePageViewController(true)
        $0.pageBreakMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.autoScales = true
    }
    private var pdfAnnotations: [PDFAnnotation]?
    private let annotationListPopOver = AnnotationListTableViewController()
    private lazy var annotationListRelay: PublishRelay<Int> = {
       let relay = PublishRelay<Int>()
        annotationListPopOver.relay = relay
        return relay
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        annotationListRelay.bind(onNext: { [weak self] row in
            self?.restoreAnnotation(self?.viewModel.getAnnotaions(row).annotation)
        }).disposed(by: disposeBag)
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
        
        let saveButton = UIButton(type: .system)
        saveButton.setTitle("save", for: .normal)
        saveButton.rx
            .controlEvent(.touchUpInside)
            .bind(onNext: { [weak self] in
                self?.saveAnnotation()
            })
            .disposed(by: disposeBag)
        
        let restoreButton = UIButton(type: .system)
        restoreButton.setTitle("restore", for: .normal)
        restoreButton.rx
            .controlEvent(.touchUpInside)
            .bind(onNext: { [weak self] in
                self?.showAnnotationList()
            })
            .disposed(by: disposeBag)
        
        navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: restoreButton),
                                               UIBarButtonItem(customView: removeButton),
                                               UIBarButtonItem(customView: saveButton)], animated: true)
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

    // MARK: -
    
    private func removeCurrentAnnotation() {
        guard let currentPage = pdfView.currentPage else { return }
        currentPage.annotations.forEach({
            currentPage.removeAnnotation($0)
        })
    }
    
    private func saveAnnotation() {
//        pdfAnnotations = pdfView.currentPage?.annotations
        
        let alertController = UIAlertController(title: "Insert annotation title.", message: nil, preferredStyle: .alert)
        alertController.addTextField { $0.text = Date.localDate.debugDescription }
        alertController.addAction(UIAlertAction(title: "cancel", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "ok", style: .default, handler: { [weak self] _ in
            let annotation = Annotation(title: alertController.textFields?.first?.text ?? "",
                                        annotation: self?.pdfView.currentPage?.annotations)
            self?.viewModel.addAnnotation(annotation)
        }))
        present(alertController, animated: true)
    }
    
    private func showAnnotationList() {
        annotationListPopOver.modalPresentationStyle = .popover
        annotationListPopOver.annotations = viewModel.allAnnotations
        let popOver = annotationListPopOver.popoverPresentationController
        popOver?.barButtonItem = navigationItem.rightBarButtonItems?.first
        present(annotationListPopOver, animated: true)
    }
    
    private func restoreAnnotation(_ restoreAnnotation: [PDFAnnotation]?) {
        annotationListPopOver.dismiss(animated: true)
        removeCurrentAnnotation()
        guard let restore = restoreAnnotation else { return }
        restore.forEach({[weak self] restoreData in
            self?.pdfView.currentPage?.addAnnotation(restoreData)
        })
    }
}
