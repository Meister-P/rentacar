//
//  Constants.swift
//  Rentacar
//
//  Created by Mikk Pavelson on 11/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import UIKit

let veriffAPIKey = "41dc1b6c-e9f2-440d-b06c-bca44061ea87"
let veriffAPISecret = "8c108d46-0c26-436b-b5a1-150689cfd541"
let veriffAPIURL = "https://api.veriff.me/v1"
let veriffSessionURL = "https://staging.veriff.me/v1/"
let veriffSessionLiveURL = "https://magic.veriff.me/v/"

let RentacarErrorDomain = "com.rentacar.error"

let RentacarCurrency = "EUR"

let UserSessionMinutes: Int = 10

typealias Action = (() -> ())

typealias RegularDicitionary = [String : AnyObject]

let ErrorImage = UIImage(named: "icn_warning")
let RentacarColor = UIColor(red: 22.0 / 255.0, green: 158.0 / 255.0, blue: 154.0 / 255.0, alpha: 1.0)
