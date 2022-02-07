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
import Thoth

final class Dummies {
    static var pdfDocument: PDFDocument? {
        guard let url = Bundle.main.url(forResource: "sample_science", withExtension: "pdf") else { return nil }
        return PDFDocument(url: url)
    }
}

final class ScribbleViewController: UIViewController {
    
    private enum BarButtonType: String, CaseIterable {
        case restore = "restore", erase = "erase", save = "save", valotile = "valotile"
    }
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
            guard let currentPage = self?.pdfView.currentPage?.pageRef?.pageNumber else { return }
            self?.restoreAnnotation(self?.viewModel.getCurrentAnnotations(currentPage)[row].annotation)
        }).disposed(by: disposeBag)
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
    
    // MARK: - setups
    
    private func setupUI() {
        title = className
        view.backgroundColor = .systemBrown
        view.addSubviews(pdfView)
        pdfView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        navigationItem.setRightBarButtonItems(setupNavButtons() ,animated: true)
        setupPDFView()
    }
    
    private func setupNavButtons() -> [UIBarButtonItem] {
        BarButtonType.allCases.map({ type in
            let barButton = UIBarButtonItem(title: type.rawValue, style: .plain, target: nil, action: nil)
            barButton.rx.tap.bind(onNext: { [weak self] _ in
                switch type {
                    case .restore:
                        self?.showAnnotationList()
                    case .erase:
                        self?.eraseCurrentAnnotation()
                    case .save:
                        self?.saveAnnotation()
                    case .valotile:
                        self?.saveValotileAnnotation()
                }
            }).disposed(by: disposeBag)
            return barButton
        })
    }

    private func setupPDFView() {
        let pdfDrawingGestureRecognizer = DrawingGestureRecognizer()
        pdfView.addGestureRecognizer(pdfDrawingGestureRecognizer)
        pdfDrawingGestureRecognizer.drawingDelegate = pdfDrawer
        pdfDrawer.pdfView = pdfView
    }

    // MARK: - Bar button actions
    
    // - restore
    private func showAnnotationList() {
        guard let currentPageNo = pdfView.currentPage?.pageRef?.pageNumber else { return }
        annotationListPopOver.modalPresentationStyle = .popover
        annotationListPopOver.annotations = viewModel.getCurrentAnnotations(currentPageNo) //viewModel.allAnnotations
        let popOver = annotationListPopOver.popoverPresentationController
        popOver?.barButtonItem = navigationItem.rightBarButtonItems?.first
        present(annotationListPopOver, animated: true)
    }
    private func restoreAnnotation(_ restoreAnnotation: [PDFAnnotation]?) {
        annotationListPopOver.dismiss(animated: true)
        eraseCurrentAnnotation()
        guard let restore = restoreAnnotation else { return }
        restore.forEach({[weak self] restoreData in
            self?.pdfView.currentPage?.addAnnotation(restoreData)
        })
    }
    // - erase
    private func eraseCurrentAnnotation() {
        guard let currentPage = pdfView.currentPage else { return }
        currentPage.annotations.forEach({
            currentPage.removeAnnotation($0)
        })
    }
    // - save
    private func saveAnnotation() {
        guard let currentPage = pdfView.currentPage?.pageRef?.pageNumber else { return }
        let alertController = UIAlertController(title: "Insert annotation title.", message: nil, preferredStyle: .alert)
        alertController.addTextField { $0.text = Date.localDate.debugDescription }
        alertController.addAction(UIAlertAction(title: "cancel", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "ok", style: .default, handler: { [weak self] _ in
            let annotation = Annotation(title: alertController.textFields?.first?.text ?? "",
                                        pageNo: currentPage,
                                        annotation: self?.pdfView.currentPage?.annotations)
            self?.viewModel.addAnnotation(annotation)
        }))
        present(alertController, animated: true)
    }
    // - valotile
    private func saveValotileAnnotation() {
    // TODO: fadeout annotations
        let alertAction = AlertAction("OK") { _ in
            print("rolllllllit")
            // 5분 뒤 표기 제거하는 기능
            // 저장 시간과 함께 리스트에 저장
        }
        showAlert("기화펜 노트", title: "5분 뒤 표기내용 제거", confirm: alertAction, cancel: AlertAction("cancel"))
    }
}
