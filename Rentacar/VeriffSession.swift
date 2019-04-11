//
//  VeriffSession.swift
//  Rentacar
//
//  Created by Mikk Pavelson on 11/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import UIKit

public enum SessionStatus: String, Codable {
    case success = "success"
}

public enum TokenStatus: String, Codable {
    case created = "created"
}

struct VeriffSession: Codable {
    let status: SessionStatus?
    let verification: Verification
}

struct Verification: Codable {
    let id: String
    let url: String
    let vendorData: String?
    let sessionToken: String
    let host: String
    let status: TokenStatus
}

//    "status": "success",
//    "verification":{
//        "id":"f04bdb47-d3be-4b28-b028-a652feb060b5",
//        "url": "https://magic.veriff.me/v/eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdXRoX3Rva2VuIjoiOXK3B_ZL51w6D_lxnGgQvhj214",
//        "sessionToken": "eyJhbGciOiJIUzI1NiIsInR5cCxnGgQvhj214",
//        "baseUrl": "https://magic.veriff.me"
//    }
