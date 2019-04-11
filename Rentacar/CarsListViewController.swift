//
//  CarsListViewController.swift
//  Rentacar
//
//  Created by Mikk Pavelson on 08/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import UIKit

class CarsListViewModel {
    var viewController: CarsListViewController!
    var carsListUpdated: Action?
    
    func refreshCarsList() {
        carsListUpdated?()
    }
}

class CarsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var viewModel: CarsListViewModel!
    private var cars = [Any]()
    
    @IBOutlet private var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        viewModel.carsListUpdated = {
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        viewModel.refreshCarsList()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CarsListCellIdentifier")
        
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "CarsListCellIdentifier")
        }
        
        // cell.populate
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
}
