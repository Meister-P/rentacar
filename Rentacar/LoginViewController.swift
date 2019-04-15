//
//  LoginViewController.swift
//  Rentacar
//
//  Created by Mikk Pavelson on 08/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import UIKit

class LoginViewModel {
    var userLoggedInSuccessfully: ((User) -> ())?
    var requestFinishedWithErrorString: ((String) -> ())?
    
    func tryLogin(email: String, password: String) {
        if let user = User.signInUserWith(email: email, password: password) {
            self.userLoggedInSuccessfully?(user)
        } else {
            self.requestFinishedWithErrorString?("User not found")
        }
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
        
        viewModel.requestFinishedWithErrorString = { [weak self] errorString in
            self?.activityIndicator.isHidden = true
            self?.showErrorAlert(errorString)
        }
        
        viewModel.userLoggedInSuccessfully = { [weak self] _ in
            self?.activityIndicator.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textFieldEmail.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldEmail {
            textFieldPassword.becomeFirstResponder()
        } else if textField == textFieldPassword {
            textFieldPassword.resignFirstResponder()
        }
        
        return true
    }
    
    @IBAction func buttonPressedLogin() {
        guard (textFieldEmail.text!.count > 0 && textFieldEmail.text!.contains("@")) else {
            textFieldEmail.shake()
            
            return
        }
        
        guard textFieldPassword.text!.count > 0 else {
            textFieldPassword.shake()
            
            return
        }
        
        activityIndicator.isHidden = false
        viewModel.tryLogin(email: textFieldEmail.text!, password: textFieldPassword.text!)
    }
}
