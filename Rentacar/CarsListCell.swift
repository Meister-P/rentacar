//
//  CarsListCell.swift
//  Rentacar
//
//  Created by Mikk Pavelson on 14/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import UIKit

class CarsListCell: UITableViewCell {
    @IBOutlet private var labelMark: UILabel!
    @IBOutlet private var labelModel: UILabel!
    @IBOutlet private var labelPrice: UILabel!
    @IBOutlet private var imageViewCar: UIImageView!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!

    func populateWith(car: Car) {
        labelMark.text = car.mark
        labelModel.text = car.model
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = RentacarCurrency
        labelPrice.text = formatter.string(from: car.priceDay as NSNumber)
        
        if let thumbnailUrl = car.thumbnailUrl, let url = URL(string: thumbnailUrl) {
            NetworkManager.downloadImageAt(url: url) { [weak self] image, error in
                
                DispatchQueue.main.async() {
                    if let image = image {
                        self?.imageViewCar.contentMode = .scaleAspectFill
                        self?.imageViewCar.image = image
                    } else if let _ = error {
                        self?.imageViewCar.contentMode = .center
                        self?.imageViewCar.image = ErrorImage
                    }
                }
            }
        }
    }
}
