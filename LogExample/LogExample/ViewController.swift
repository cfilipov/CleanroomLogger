//
//  ViewController.swift
//  LogExample
//
//  Created by CF on 3/2/17.
//  Copyright © 2017 CF. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    private let dataSource = liveLogInspectorConfiguration.inspectorViewDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         Using a grouped style table view looks nicer when the log hasn't yet filled the screen.
         But we need to adjust the content insets so the top and bottom rows are flush.
         */
        tableView.contentInset = UIEdgeInsets(top: -36, left: 0, bottom: -38, right: 0)
        
        /*
         Demonstrate using an existing custom tableView to present the live log using the data source directly.
         */
        dataSource.tableView = tableView
    }

    /*
     Demonstrate presenting the live log inspector view controller.
     */
    @IBAction func onLogButtonPressed() {
        present(liveLogInspectorConfiguration.inspectorViewController(), animated: true, completion: nil)
    }

}

