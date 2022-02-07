//
//  PDFCanvasViewController.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2021/12/27.
//

import UIKit
import PencilKit
import RxSwift
import SnapKit
import Then
import Thoth

final class PDFCanvasViewController: UIViewController {

    private lazy var viewModel = PDFCanvasViewModel(self)
    private var rendition: Rendition?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
    }

    private func setupUI() {
        view.backgroundColor = .systemPurple
        title = className
        let barButtons = getNavButtons().map({ UIBarButtonItem(customView: $0) })
        navigationItem.setRightBarButtonItems(barButtons, animated: true)
        
        // # add canvasView
        view.addSubviews(viewModel.canvasView)
        viewModel.canvasView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
//            $0.edges.size.equalTo(viewModel.getPdfSize())
        }
        // # insert pdfViewer on canvasView
        viewModel.addPdfViewerOnCanvas()
        viewModel.pdfViewer.snp.makeConstraints {
            $0.edges.equalToSuperview() //equalTo(view.safeAreaLayoutGuide)
        }
        
        // sizing
        let pdfViewerSize = CGSize(width: UIScreen.width, height: UIScreen.height-70) // CGSize(width: 1000, height: 1000)
//        viewModel.pdfViewer.frame = CGRect(origin: .zero, size: pdfViewerSize)
        viewModel.canvasView.contentSize = pdfViewerSize // viewModel.getPdfSize()
        viewModel.canvasView.subviews.forEach({ $0.frame = CGRect(origin: .zero, size: pdfViewerSize) })
        
        // FIXME: inspecting...
        viewModel.canvasView.debugBounds(.blue, 2)
        viewModel.pdfViewer.debugBounds(.white, 4)
    }

    private func setupRx() {
//        viewModel.canvasView.rx.didZoom
//            .bind(onNext: { [weak self] in
//                print("\(self?.canvasView.zoomScale.description)")
//            })
//            .disposed(by: disposeBag)
    }
    
    /*
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch touches.first?.type {
        case .pencil:
            print(1)
        case .direct:
            print(2)
        default: break
        }
    }
    */

    private func getNavButtons() -> [UIView] {
        // save
        let saveButton = UIButton()
        saveButton.setTitle("save", for: .normal)
        saveButton.rx.controlEvent(.touchUpInside)
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.viewModel.saveCanvasToAlbum() { [weak self] in
                    self?.showAlert("your drawing has successfully saved!", title: "saved!", confirm: AlertAction("OK"))
//                    self.rendition = Rendition(title: "rendit", image: image, drawing: canvasView.drawing)
                }
            })
            .disposed(by: disposeBag)
        // delete
        let deleteButton = UIButton()
        deleteButton.setTitle("delete", for: .normal)
        deleteButton.rx.controlEvent(.touchUpInside)
            .bind(onNext: { [weak self] _ in
                self?.viewModel.canvasView.drawing = PKDrawing()
            })
            .disposed(by: disposeBag)
        // restore
//        let restoreButton = UIButton()
//        restoreButton.setTitle("restore", for: .normal)
//        restoreButton.rx.controlEvent(.touchUpInside)
//            .bind(onNext: { [weak self] _ in
//                guard let rendition = self?.rendition else { return }
//                self?.viewModel.canvasView.drawing = rendition.drawing
//            })
//            .disposed(by: disposeBag)
        
        return [saveButton, deleteButton]
    }
}

extension PDFCanvasViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
//        saveDrawing()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        viewModel.setPdfViewerZoomScale(scrollView.zoomScale)
    }
}
