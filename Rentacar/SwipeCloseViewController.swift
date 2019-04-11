//
//  SwipeCloseViewController.swift
//  Rentacar
//
//  Created by Mikk Pavelson on 11/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import UIKit

extension Selector {
    static let dismiss = #selector(SwipeCloseViewController.dismissController)
}

class SwipeCloseViewController: UIViewController {
    var closeController: Action?
    
    @objc fileprivate func dismissController() {
        closeController?()
    }
}
