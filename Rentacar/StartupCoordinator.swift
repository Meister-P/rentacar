//
//  StartupCoordinator.swift
//  Rentacar
//
//  Created by Mikk Pavelson on 08/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import UIKit
import CoreData
import Foundation

class StartupCoordinator: NSObject, Coordinator {
    private weak var rootViewController: StartupViewController!
    
    init(viewController: StartupViewController) {
        self.rootViewController = viewController
    }
    
    func start() {
        if let session = User.sharedUser()?.session, session.isValid {
            showCarsListView()
        } else {
            showLoginAndSignup()
        }
    }
    
    func showLoginAndSignup() {
        let selectionViewController = LoginSignupSelectionViewController.getInstance() as! LoginSignupSelectionViewController
        selectionViewController.loginSelected = { [weak self] in
            self?.showLoginView()
        }
        selectionViewController.signupSelected = { [weak self] in
            self?.showSignupView()
        }
        
        rootViewController.present(selectionViewController, animated: true, completion: nil)
    }
    
    func showSignupView() {
        let signupController = SignupViewController.getInstance() as! SignupViewController
        signupController.closeController = {
            signupController.dismiss(animated: true) {
                self.showLoginAndSignup()
            }
        }
        
        rootViewController.dismiss(animated: true) {
            self.rootViewController.present(signupController, animated: true, completion: nil)
        }
        
        signupController.viewModel.userSignupFinishedSuccessfully = { [weak self] in
            self?.rootViewController.dismiss(animated: true) { [weak self] in
                self?.showCarsListView()
            }
        }
    }
    
    func showLoginView() {
        let loginViewController = LoginViewController.getInstance() as! LoginViewController
        self.rootViewController.dismiss(animated: true) { [weak self] in
            self?.rootViewController.present(loginViewController, animated: true, completion: nil)
        }
        
        loginViewController.closeController = { [weak loginViewController] in
            loginViewController?.dismiss(animated: true) { [weak self] in
                self?.showLoginAndSignup()
            }
        }
        
        loginViewController.viewModel.userLoggedInSuccessfully = { [weak self] _ in
            self?.rootViewController.dismiss(animated: true) {
                self?.showCarsListView()
            }
        }
    }
    
    var carNavigationController: UINavigationController?
    
    private func showCarsListView() {
        carNavigationController = CarsListViewController.getNavigationController()
        let carsListViewController = carNavigationController!.viewControllers.first! as! CarsListViewController
        carNavigationController!.navigationBar.tintColor = RentacarColor
        carsListViewController.viewModel.carSelected = { [weak self] car in
            self?.show(car: car)
        }
        carsListViewController.viewModel.logoutAction = { [weak self] in
            self?.logout()
        }
        
        rootViewController.present(carNavigationController!, animated: true, completion: nil)
    }
    
    private func show(car: Car) {
        let carViewController = CarViewController.getInstance() as! CarViewController
        carViewController.viewModel = CarViewModel(car: car)
        carNavigationController!.pushViewController(carViewController, animated: true)
        
        carViewController.viewModel.carBooked = { [weak self] car in
            
        }
    }
    
    func logout() {
        User.sharedUser()!.logout()
        
        rootViewController.dismiss(animated: true) { [weak self] in
            self?.showLoginAndSignup()
        }
    }
}
