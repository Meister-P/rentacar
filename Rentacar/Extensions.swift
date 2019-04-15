//
//  Extensions.swift
//  Rentacar
//
//  Created by Mikk Pavelson on 08/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import UIKit
import CommonCrypto

extension NSObject {
    class var className: String {
        return String(describing: self)
    }
    
    var className: String {
        return String(describing: type(of: self))
    }
}

extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return storyboardNamed("Main")
    }
    
    class func storyboardNamed(_ name: String, bundle: Bundle = Bundle.main) -> UIStoryboard {
        return UIStoryboard(name: name, bundle: bundle)
    }
}

extension Date {
    func dateInNumberOfMinutes(_ minutes: Int) -> Date {
        return self.addingTimeInterval(60 * Double(minutes))
    }
    
    var isFuture: Bool {
        let now = Date()
        
        return self > now
    }
}

extension UIViewController {
    class func getInstance<T: UIViewController>() -> T {
        return UIStoryboard.mainStoryboard().instantiateViewController(withIdentifier: className) as! T
    }
    
    func showErrorAlert(_ errorString: String) {
        let alertController = UIAlertController(title: "Error ocurred", message: errorString, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension UIView {
    func shake() {
        let anim = CAKeyframeAnimation( keyPath:"transform" )
        anim.values = [
            NSValue( caTransform3D:CATransform3DMakeTranslation(-5, 0, 0 ) ),
            NSValue( caTransform3D:CATransform3DMakeTranslation( 5, 0, 0 ) )
        ]
        anim.autoreverses = true
        anim.repeatCount = 2
        anim.duration = 7/100
        
        self.layer.add( anim, forKey:nil )
    }
}

extension String {
    func sha256() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }
        
        return ""
    }
    
    private func digest(input : NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }
    
    private  func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        
        var hexString = ""
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
}
