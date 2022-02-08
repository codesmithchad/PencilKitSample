//
//  PlayGroundViewController.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2021/12/27.
//

import UIKit
import RxSwift
import RxCocoa
import PDFKit
import Thoth
import SnapKit

final class PlayGroundViewController: UIViewController, UITableViewDataSource {
    
    private let dataManager = CoreDataController()
    private let disposeBag = DisposeBag()
    private var writingModel = CoreDataController.WritingModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let tableView = UITableView()
        tableView.debugBounds(.orange)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        
        dataManager.fetch()
        tableView.reloadData()
        
        let textFields: [UITextField] = ["scribble type", "title"].enumerated().map {
            let textField = UITextField()
            textField.placeholder = $0.element
            textField.tag = $0.offset
            textField.debugBounds()
            textField.rx.text.orEmpty.bind(onNext: { [unowned self] message in
                switch textField.tag {
                    case 0:
                        self.writingModel.scribbleType = .note
                    default:
                        self.writingModel.title = message
                }
            }).disposed(by: disposeBag)
            return textField
        }
        let stackView = UIStackView(arrangedSubviews: textFields)
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 4
        stackView.debugBounds(.green)
        
        let submitButton = UIButton()
        submitButton.setTitle("submit", for: .normal)
        submitButton.setTitleColor(.red, for: .normal)
        submitButton.debugBounds(.blue)
        submitButton.rx.controlEvent(.touchUpInside).bind(onNext: { [unowned self] in
            self.dataManager.save(self.writingModel) {
                self.dataManager.fetch()
                tableView.reloadData()
                tableView.scrollToRow(at: IndexPath(row: dataManager.writings.count-1, section: 0), at: .bottom, animated: true)
            }
        }).disposed(by: disposeBag)
        
        view.addSubviews(stackView, submitButton, tableView)
        submitButton.snp.makeConstraints {
            $0.top.right.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.width.height.equalTo(160)
        }
        stackView.snp.makeConstraints {
            $0.top.left.equalTo(view.safeAreaLayoutGuide).inset(10)
            $0.right.equalTo(submitButton.snp.left)
            $0.height.equalTo(160)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(4)
            $0.left.bottom.right.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { dataManager.writings.count}
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var configuration = cell.defaultContentConfiguration()
        let writing = dataManager.writings[indexPath.row]
        configuration.text = writing.value(forKey: "title") as? String
        configuration.secondaryText = (writing.value(forKey: "createdAt") as? Date)?.toStringKST()
        cell.contentConfiguration = configuration
        return cell
    }
}









/*
final class PlayGroundViewController: UIViewController {

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
*/
