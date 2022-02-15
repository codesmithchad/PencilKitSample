//
//  AnnotationListTableViewController.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2022/01/19.
//

import UIKit
import RxSwift
import RxRelay
import CoreData
import PDFKit

final class AnnotationListTableViewController: UITableViewController {
    
    var annotations = [Annotation]()
    var relay = PublishRelay<[PDFAnnotation]>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = .darkGray
        tableView.register(AnnotationListTableViewCell.self, forCellReuseIdentifier: AnnotationListTableViewCell.description())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { annotations.count }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AnnotationListTableViewCell.description(), for: indexPath) as? AnnotationListTableViewCell else {
            return UITableViewCell()
        }
        cell.textLabel?.text = annotations[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedAnnotation = annotations[indexPath.row]
        if let scribbles = selectedAnnotation.annotation {
            relay.accept(scribbles)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let selectedAnnotation = annotations[indexPath.row]
//            // TODO: remove row data
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
    }
}

final class AnnotationListTableViewCell: UITableViewCell  {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
