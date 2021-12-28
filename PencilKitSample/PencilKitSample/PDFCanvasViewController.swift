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

    private let viewModel = PDFCanvasViewModel()
    private var rendition: Rendition?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
    }

    private func setupUI() {
        title = className
        let barButtons = getNavButtons().map({ UIBarButtonItem(customView: $0) })
        navigationItem.setRightBarButtonItems(barButtons, animated: true)
        
        viewModel.canvasView.addSubview(viewModel.pdfViewer)
        viewModel.canvasView.layer.zPosition = 1
        
        view.addSubviews(viewModel.canvasView)  // viewModel.pdfViewer,
        viewModel.canvasView.snp.makeConstraints {
            $0.top.bottom.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.width.equalTo(10)
        }
        viewModel.pdfViewer.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        viewModel.canvasView.delegate = self
        viewModel.showToolPicker(viewModel.canvasView)
        
        // .mediaBox .cropBox .bleedBox .trimBox .artBox
        if let pdfSize = viewModel.pdfViewer.currentPage?.bounds(for: .mediaBox) {
            viewModel.canvasView.snp.updateConstraints {
                $0.width.equalTo(pdfSize.width)
            }
        }
    }

    private func setupRx() {
//        viewModel.canvasView.rx.didZoom
//            .bind(onNext: { [weak self] in
//                print("\(self?.canvasView.zoomScale.description)")
//            })
//            .disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch touches.first?.type {
        case .pencil:
            print(1)
        case .direct:
            print(2)
        default: break
        }
    }

    private func getNavButtons() -> [UIView] {
        let saveButton = UIButton()
        saveButton.setTitle("save", for: .normal)
        saveButton.rx.controlEvent(.touchUpInside)
            .bind(onNext: { [weak self] _ in
                self?.saveToAlbum()
            })
            .disposed(by: disposeBag)
        
        let deleteButton = UIButton()
        deleteButton.setTitle("delete", for: .normal)
        deleteButton.rx.controlEvent(.touchUpInside)
            .bind(onNext: { [weak self] _ in
                self?.deleteDrawing()
            })
            .disposed(by: disposeBag)
        
//        let restoreButton = UIButton()
//        restoreButton.setTitle("restore", for: .normal)
//        restoreButton.rx.controlEvent(.touchUpInside)
//            .bind(onNext: { [weak self] _ in
//                  self?.restoreDrawing()
//              })
//            .disposed(by: disposeBag)
        return [saveButton, deleteButton]
    }

    private func saveToAlbum() {
        
        viewModel.saveCanvasToAlbum(viewModel.canvasView) { [weak self] in
            self?.showAlert("your drawing has successfully saved!", title: "saved!", confirm: AlertAction("OK"))
//            self?.rendition = Rendition(title: "rendit", image: image, drawing: canvasView.drawing)
        }
    }

    private func deleteDrawing() {
        viewModel.canvasView.drawing = PKDrawing()
    }

    private func restoreDrawing() {
        guard let rendition = rendition else { return }
        viewModel.canvasView.drawing = rendition.drawing
    }
}

extension PDFCanvasViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
//        saveDrawing()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        viewModel.pdfViewer.setZoomScale(scrollView.zoomScale)
    }
}
