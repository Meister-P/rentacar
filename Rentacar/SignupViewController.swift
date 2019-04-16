//
//  SignupViewController.swift
//  Rentacar
//
//  Created by Mikk Pavelson on 08/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import UIKit
import Veriff

class SignupViewModel: NSObject, VeriffDelegate {
    var requestFinishedWithErrorString: ((String) -> ())?
    var userSignupFinishedSuccessfully: (() -> ())?
    
    func signupUser(firstName: String, lastName: String, email: String, password: String) {
        if let _ = User.findUserWith(email: email) {
            requestFinishedWithErrorString?("A user with this email already exists")
        } else {
            dataStore.createNewUserWith(firstName: firstName, lastName: lastName, email: email, password: password)
            userSignupFinishedSuccessfully?()
//            self.startVeriffSession(firstName: firstName, lastName: lastName)
        }
    }
    
    private func startVeriffSession(firstName: String, lastName: String) {
        NetworkManager.startVeriffSession(firstName: firstName, lastName: lastName) { [weak self]
            session, error in
            
            if let error = error {
                self?.requestFinishedWithErrorString?(error.localizedDescription)
            } else if let session = session {
                self?.verifyUserAfterSignup(veriffSession: session)
            }
        }
    }
  
    private func verifyUserAfterSignup(veriffSession: VeriffSession) {
        let conf = VeriffConfiguration(sessionToken: veriffSession.verification.sessionToken, sessionUrl: veriffSession.verification.host)
        let veriff = Veriff.shared
        veriff.delegate = self
        veriff.set(configuration: conf)
        veriff.startAuthentication()
    }
    
    func onSession(result: VeriffResult, sessionToken: String) {
        switch result.code {
        case .UNABLE_TO_ACCESS_CAMERA:
            print("User denied access to the camera")
        case .STATUS_USER_CANCELED:
            print("User canceled the verification process")
        case .STATUS_SUBMITTED:
            print("User submitted the photos or finished video call")
        case .STATUS_ERROR_SESSION:
            print("The session token is either corrupt, or has expired. A new sessionToken needs to be generated in this case")
        case .STATUS_ERROR_NETWORK:
            print("SDK could not connect to backend servers.")
        case .STATUS_ERROR_NO_IDENTIFICATION_METHODS_AVAILABLE:
            print("Given session cannot be started as there are no identification methods")
        case .STATUS_DONE:
            print("The session status is finished from clients perspective")
        case .STATUS_ERROR_UNKNOWN:
            print("Verification status unknown")
        }
    }
}

class SignupViewController: SwipeCloseViewController, UITextFieldDelegate {
    var viewModel = SignupViewModel()
    @IBOutlet private var textFieldFirstName: UITextField!
    @IBOutlet private var textFieldLastName: UITextField!
    @IBOutlet private var textFieldEmail: UITextField!
    @IBOutlet private var textFieldPassword: UITextField!
    @IBOutlet private var buttonGo: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonGo.layer.cornerRadius = 4.0
        
        textFieldFirstName.layer.cornerRadius = 4.0
        textFieldFirstName.returnKeyType = .next
        textFieldFirstName.delegate = self
        
        textFieldLastName.layer.cornerRadius = 4.0
        textFieldLastName.returnKeyType = .next
        textFieldLastName.delegate = self
        
        textFieldEmail.layer.cornerRadius = 4.0
        textFieldEmail.keyboardType = .emailAddress
        textFieldEmail.returnKeyType = .next
        textFieldEmail.delegate = self
        
        textFieldPassword.layer.cornerRadius = 4.0
        textFieldPassword.returnKeyType = .done
        textFieldPassword.delegate = self
        
        viewModel.requestFinishedWithErrorString = {
            error in
            
            self.activityIndicator.isHidden = true
            self.showErrorAlert(error)
        }
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: .dismiss)
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        // debug
        textFieldFirstName.text = "Mikk"
        textFieldLastName.text = "Pavelson"
        textFieldEmail.text = "mikk.pavelson@gmail.com"
        textFieldPassword.text = "password"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        textFieldFirstName.becomeFirstResponder()
    }
    
    // MARK: - Text field delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldFirstName {
            textFieldLastName.becomeFirstResponder()
        } else if textField == textFieldLastName {
            textFieldEmail.becomeFirstResponder()
        } else if textField == textFieldEmail {
            textFieldPassword.becomeFirstResponder()
        } else if textField == textFieldPassword {
            textFieldPassword.resignFirstResponder()
        }
        
        return true
    }
    
    // MARK: -
    
    @IBAction private func buttonGoPressed() {
        guard textFieldFirstName.text!.count > 0 else {
            textFieldFirstName.shake()
            
            return
        }
        
        guard textFieldLastName.text!.count > 0 else {
            textFieldLastName.shake()
            
            return
        }
        
        guard textFieldEmail.text!.count > 0 else {
            textFieldEmail.shake()
            
            return
        }
        
        guard textFieldPassword.text!.count > 0 else {
            textFieldPassword.shake()
            
            return
        }
        
        activityIndicator.isHidden = false
        viewModel.signupUser(firstName: textFieldFirstName.text!, lastName: textFieldLastName.text!, email: textFieldEmail.text!, password: textFieldPassword.text!)
    }
    
}

