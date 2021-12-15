//
//  ViewController.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2021/12/15.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import PencilKit

final class ViewController: UIViewController {

    private var canvasView = PKCanvasView().then {
        $0.tool = PKInkingTool(.pen, color: .gray, width: 20)
        $0.drawingPolicy = .anyInput
        $0.backgroundColor = .clear //UIColor.black.withAlphaComponent(0.1)
    }
    private let toolPicker = PKToolPicker()
    private var rendition: Rendition?
    private let disposeBag = DisposeBag()
    private let saveButton = UIButton()
    private let deleteButton = UIButton()
    private let restoreButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
    }

    private func setupUI() {
        let bgImageView = getBgImage()
        let hStack = UIStackView(arrangedSubviews: getButtons()).then {
            $0.axis = .horizontal
            $0.spacing = 10
        }
        view.addSubviews(bgImageView, canvasView, hStack)
        bgImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        canvasView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        hStack.snp.makeConstraints {
            $0.top.left.equalToSuperview().offset(28)
        }

        canvasView.delegate = self
        showToolPicker()
    }

    private func setupRx() {
        saveButton.rx.controlEvent(.touchUpInside)
            .bind(onNext: { [weak self] _ in
                self?.saveToAlbum()
            })
            .disposed(by: disposeBag)
        deleteButton.rx.controlEvent(.touchUpInside)
            .bind(onNext: { [weak self] _ in
                self?.deleteDrawing()
            })
            .disposed(by: disposeBag)
//        restoreButton.rx.controlEvent(.touchUpInside)
//            .bind(onNext: { [weak self] _ in
//                  self?.restoreDrawing()
//              })
//            .disposed(by: disposeBag)
    }

    private func getBgImage() -> UIImageView {
        let data = try! Data(contentsOf: URL(string: "https://picsum.photos/1133/744")!) // 1133/744 4532/2976
        let imageView = UIImageView(image: UIImage(data: data))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private func getButtons() -> [UIView] {
        saveButton.setTitle("save", for: .normal)
        deleteButton.setTitle("delete", for: .normal)
//        restoreButton.setTitle("restore", for: .normal)
        return [saveButton, deleteButton]
    }

    private func saveToAlbum() {
//        let image = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
//        UIImageWriteToSavedPhotosAlbum(image, self, #selector(savedAlert), nil)

//        dump(canvasView.drawing.strokes)

        savedAlert()
    }
    @objc func savedAlert() {
        let alert = UIAlertController(title: "saved!", message: "your drawing has successfully saved!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

//    private func saveDrawing() {
//        let image = canvasView.drawing.image(from: canvasView.bounds, scale: UIScreen.main.scale)
//        self.rendition = Rendition(title: "rendit", image: image, drawing: canvasView.drawing)
//    }

    private func deleteDrawing() {
        canvasView.drawing = PKDrawing()
    }

    private func restoreDrawing() {
        guard let rendition = rendition else { return }
        canvasView.drawing = rendition.drawing
    }

    private func showToolPicker() {
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        toolPicker.addObserver(canvasView)
        canvasView.becomeFirstResponder()
    }
}

extension ViewController: PKCanvasViewDelegate {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
//        saveDrawing()
    }
}

struct Rendition {
    let title: String
    let image: UIImage
    let drawing: PKDrawing
}

extension UIView {
    func addSubviews(_ subviews: UIView...) {
        for subview in subviews {
            addSubview(subview)
        }
    }
}

