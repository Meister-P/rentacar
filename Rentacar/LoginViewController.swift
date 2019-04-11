//
//  LoginViewController.swift
//  Rentacar
//
//  Created by Mikk Pavelson on 08/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import UIKit

class LoginViewModel {
    var requestFinishedWithError: ((Error) -> ())?
    var userLoggedInSuccessfully: (() -> ())?
    
    func tryLogin(email: String, password: String) {
//        Auth.auth().signIn(withEmail: email, password: password) { [weak self]
//            result, error in
//
//            if let error = error {
//                self?.requestFinishedWithError?(error)
//            } else if let user = result?.user {
//                self?.userLoggedInSuccessfully?(user)
//            }
//        }
    }
}

class LoginViewController: SwipeCloseViewController, UITextFieldDelegate {
    var viewModel = LoginViewModel()
    @IBOutlet private var textFieldEmail: UITextField!
    @IBOutlet private var textFieldPassword: UITextField!
    @IBOutlet private var buttonLogIn: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()

        buttonLogIn.layer.cornerRadius = 4.0
        
        textFieldEmail.layer.cornerRadius = 4.0
        textFieldEmail.keyboardType = .emailAddress
        textFieldEmail.returnKeyType = .next
        textFieldEmail.delegate = self
        
        textFieldPassword.layer.cornerRadius = 4.0
        textFieldPassword.returnKeyType = .done
        textFieldPassword.delegate = self
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: .dismiss)
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        viewModel.requestFinishedWithError = {
            error in
            
            self.activityIndicator.isHidden = true
            self.showErrorAlert(error.localizedDescription)
        }
        
        viewModel.userLoggedInSuccessfully = {
            self.activityIndicator.isHidden = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldEmail {
            textFieldPassword.becomeFirstResponder()
        } else if textField == textFieldPassword {
            textFieldPassword.resignFirstResponder()
        }
        
        return true
    }
}
