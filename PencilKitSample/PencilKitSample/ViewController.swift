//
//  ViewController.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2021/12/15.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import Thoth

final class ViewController: UIViewController {
    
    static let list: [UIViewController] = [ScribbleViewController(),
//                                           CanvasOnPdfViewController(),
//                                           PDFCanvasViewController(),
                                           PlayGroundViewController()]
    
    private let disposeBag = DisposeBag()
    private let tableView = UITableView().then {
        $0.register(ListCell.self, forCellReuseIdentifier: ListCell.identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
    }
    
    private func setupUI() {
        title = self.className
        view.addSubviews(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let table = self?.tableView else { return }
            table.delegate?.tableView?(table, didSelectRowAt: IndexPath().zero)
        }
    }
    
    private func setupRx() {
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        bindTableView()
    }
    
    // MARK: - Table view
    
    typealias ListSectionModel = SectionModel<String, String>
    typealias ListDataSource = RxTableViewSectionedReloadDataSource<ListSectionModel>
    
    private func bindTableView() {
        let sections = [SectionModel<String, String>(model: "first section", items: Self.list.map({ $0.className }))]
        Observable.just(sections)
            .bind(to: tableView.rx.items(dataSource: listDataSource))
            .disposed(by: disposeBag)
        tableView.rx.itemSelected
            .bind(onNext: { [weak self] indexPath in
                self?.navigationController?.pushViewController(Self.list[indexPath.row], animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private var listDataSource: ListDataSource {
        typealias ConfigureCell = (TableViewSectionedDataSource<ListSectionModel>, UITableView, IndexPath, String) -> UITableViewCell
        let configureCell: ConfigureCell = { dataSource, tableView, indexPath, element in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.identifier, for: indexPath) as? ListCell else { return UITableViewCell() }
            cell.titleLabel.text = element
            return cell
        }
        
        let dataSource = ListDataSource(configureCell: configureCell)
        return dataSource
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 100 }
}

private class ListCell: UITableViewCell {
    static let identifier = description()
    let titleLabel = UILabel()
//        .then {
//        $0.debugBounds()
//    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubviews(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
    }
}
