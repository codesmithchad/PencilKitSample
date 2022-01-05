//
//  ScribbleViewController.swift
//  PencilKitSample
//
//  Created by Ajiaco on 2022/01/03.
//

import UIKit

final class ScribbleViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRx()
    }
    
    private func setupUI() {
        title = className
        view.backgroundColor = .systemBrown
    }
    
    private func setupRx() {
        
    }
    
}
