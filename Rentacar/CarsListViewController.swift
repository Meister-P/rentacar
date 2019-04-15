//
//  CarsListViewController.swift
//  Rentacar
//
//  Created by Mikk Pavelson on 08/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import UIKit

fileprivate extension Selector {
    static let logout = #selector(CarsListViewController.logout)
}

let CarsListNavigationControllerStoryboardID = "CarsListNavigationController"

class CarsListViewModel: NSObject {
    var viewController: CarsListViewController!
    var carsListUpdated: (([Car]) -> ())?
    var carSelected: ((Car) -> ())?
    var logoutAction: Action?
    
    func refreshCarsList() {
        let cars = dataStore.fetchAllEntitiesOfType(Car.self)
        carsListUpdated?(cars)
    }
    
    @objc func logout() {
        logoutAction?()
    }
}

class CarsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var viewModel = CarsListViewModel()
    private var cars = [Car]()
    @IBOutlet private var tableView: UITableView!
    
    class func getNavigationController() -> UINavigationController {
        let navigationController = UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: CarsListNavigationControllerStoryboardID) as! UINavigationController
        return navigationController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Cars"
        
        let cancelButtonItem = UIBarButtonItem(title: "Log out", style: .plain, target: viewModel, action: .logout)
        UIBarButtonItem.appearance().tintColor = RentacarColor
        navigationItem.leftBarButtonItem = cancelButtonItem

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: CarsListCell.className, bundle: nil), forCellReuseIdentifier: CarsListCell.className)
        
        viewModel.carsListUpdated = { [weak self] cars in
            self?.cars = cars
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        viewModel.refreshCarsList()
    }
    
    @objc func logout() {
        let alertController = UIAlertController(title: "Log out", message: "Are you sure you want to log out?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "Log out", style: .default) { [weak self] _ in
            self?.viewModel.logout()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Table view

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: CarsListCell = tableView.dequeueReusableCell(withIdentifier: CarsListCell.className) as! CarsListCell
        let car = cars[indexPath.row]
        cell.populateWith(car: car)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let car = cars[indexPath.row]
        viewModel.carSelected?(car)
    }
}
