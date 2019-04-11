//
//  LoginSignupSelectionViewController.swift
//  Rentacar
//
//  Created by Mikk Pavelson on 08/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import UIKit

class SelectionViewModel {
    
}

class LoginSignupSelectionViewController: UIViewController {
    var viewModel = SelectionViewModel()
    @IBOutlet fileprivate var buttonLogin: UIButton!
    @IBOutlet fileprivate var buttonSignup: UIButton!
    var loginSelected: Action?
    var signupSelected: Action?
    
    @IBAction func buttonLoginPressed() {
        loginSelected?()
    }
    
    @IBAction func buttonSignupPressed() {
        signupSelected?()
    }
}
