//
//  StartupCoordinator.swift
//  Rentacar
//
//  Created by Mikk Pavelson on 08/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import UIKit

class StartupCoordinator: Coordinator {
    private weak var rootViewController: StartupViewController!

    
    init(viewController: StartupViewController) {
        self.rootViewController = viewController
    }
    
    func start() {
//        if let user = Auth.auth().currentUser {
//            // showCarsListView()
////            showLoginAndSignup()
//            databaseReference.child("users").child(user.uid).observeSingleEvent(of: .value, with: { (snapshot) in
//                // Get user value
//                let value = snapshot.value as? NSDictionary
//                print("snapshot: \(snapshot)")
//            }) { (error) in
//                print(error.localizedDescription)
//            }
//        } else {
//            showLoginAndSignup()
//        }
//        
//        databaseReference = Database.database().reference()
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
            
            self?.rootViewController.dismiss(animated: true) {
                self?.showCarsListView()
            }
        }
    }
    
    func showLoginView() {
        let loginViewController = LoginViewController.getInstance() as! LoginViewController
        rootViewController.present(loginViewController, animated: true, completion: nil)
        
        loginViewController.closeController = { [weak loginViewController] in
            loginViewController?.dismiss(animated: true) { [weak self] in
                self?.showLoginAndSignup()
            }
        }
        
        loginViewController.viewModel.userLoggedInSuccessfully = { [weak self] in
            self?.rootViewController.dismiss(animated: true) {
                self?.showCarsListView()
            }
        }
    }
    
    // MARK: - Private
    
    private func showLoginAndSignup() {
        let selectionViewController = LoginSignupSelectionViewController.getInstance() as! LoginSignupSelectionViewController
        selectionViewController.loginSelected = { [weak self] in
            self?.showLoginView()
        }
        selectionViewController.signupSelected = { [weak self] in
            self?.showSignupView()
        }
        
        rootViewController.present(selectionViewController, animated: true, completion: nil)
    }
    
    private func showCarsListView() {
        let carsListViewModel = CarsListViewModel()
        let carsListViewController = CarsListViewController.getInstance() as! CarsListViewController
        carsListViewModel.viewController = carsListViewController
        
        rootViewController.present(carsListViewController, animated: true, completion: nil)
    }
}
