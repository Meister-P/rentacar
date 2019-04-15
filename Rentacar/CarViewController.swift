//
//  CarViewController.swift
//  Rentacar
//
//  Created by Mikk Pavelson on 14/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import UIKit

class CarViewModel: NSObject {
    var car: Car!
    var carBooked:((Car) -> ())?
    
    init(car: Car) {
        self.car = car
    }
    
    func carBookedPressed() {
        carBooked?(car)
    }
}

class CarViewController: UIViewController {
    var viewModel: CarViewModel!
    @IBOutlet private var labelMark: UILabel!
    @IBOutlet private var labelModel: UILabel!
    @IBOutlet private var labelPrice: UILabel!
    @IBOutlet private var imageViewCar: UIImageView!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var buttonBook: UIButton!
    @IBOutlet private var datePicker: UIDatePicker!
    @IBOutlet private var datePickerConstraintBottom: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Car details"
        
        buttonBook.layer.cornerRadius = 4.0

        labelMark.text = "Mark: \(viewModel.car.mark!)"
        labelModel.text = "Model: \(viewModel.car.model!)"
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = RentacarCurrency
        labelPrice.text = "Price: \(formatter.string(from: viewModel.car.priceDay as NSNumber)!)"
        
        if let imageUrl = viewModel.car.imageUrl, let url = URL(string: imageUrl) {
            NetworkManager.downloadImageAt(url: url) { [weak self] image, error in
                
                DispatchQueue.main.async() {
                    if let image = image {
                        self?.imageViewCar.contentMode = .scaleAspectFit
                        self?.imageViewCar.image = image
                    } else if let _ = error {
                        self?.imageViewCar.contentMode = .center
                        self?.imageViewCar.image = ErrorImage
                    }
                }
            }
        }
    }
    
    @IBAction func buttonPressedBook() {
        viewModel.carBookedPressed()
    }
    
}
