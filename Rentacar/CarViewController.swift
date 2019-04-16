//
//  CarViewController.swift
//  Rentacar
//
//  Created by Mikk Pavelson on 14/04/2019.
//  Copyright © 2019 Mikk Pavelson. All rights reserved.
//

import UIKit

fileprivate extension Selector {
    static let datePickerValueChanged = #selector(CarViewController.datePickerValueChanged)
    static let hidePicker = #selector(CarViewController.hidePicker)
}

class CarViewModel: NSObject {
    var car: Car!
    var carBooked:((Car, Date, Date) -> ())?
    
    init(car: Car) {
        self.car = car
    }
    
    func carBookedPressed(start: Date, end: Date) {
        carBooked?(car, start, end)
    }
}

class CarViewController: UIViewController, UITextFieldDelegate {
    var viewModel: CarViewModel!
    @IBOutlet private var labelMark: UILabel!
    @IBOutlet private var labelModel: UILabel!
    @IBOutlet private var labelPrice: UILabel!
    @IBOutlet private var imageViewCar: UIImageView!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var buttonBook: UIButton!
    private var datePicker: UIDatePicker!
    @IBOutlet private var datePickerConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var textFieldStartDate: UITextField!
    @IBOutlet weak var textFieldEndDate: UITextField!
    private var activeTextField: UITextField!
    private let formatter = NumberFormatter()
    private let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Car details"
        
        buttonBook.layer.cornerRadius = 4.0

        labelMark.text = "Mark: \(viewModel.car.mark!)"
        labelModel.text = "Model: \(viewModel.car.model!)"
        
        textFieldStartDate.layer.cornerRadius = 4.0
        textFieldStartDate.delegate = self
        textFieldEndDate.layer.cornerRadius = 4.0
        textFieldEndDate.delegate = self
        
        datePicker = UIDatePicker()
        datePicker.addTarget(self, action: .datePickerValueChanged, for: .valueChanged)
        datePicker.minimumDate = Date()
        
        textFieldEndDate.inputView = datePicker
        textFieldStartDate.inputView = datePicker
        
        let toolbar = UIToolbar()
        toolbar.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: .hidePicker)
        button.title = "Done"
        button.tintColor = RentacarColor
        toolbar.setItems([button], animated: false)
        
        textFieldStartDate.inputAccessoryView = toolbar
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: .hidePicker)
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        
        datePickerConstraintBottom.constant = 0.0
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.setNeedsLayout()
        }
        
        if textField == textFieldStartDate {
            datePicker.minimumDate = Date()
        } else {
            datePicker.minimumDate = Date().dateInNumberOfDays(1)
        }
    }
    
    @objc func hidePicker() {
        datePickerConstraintBottom.constant = datePicker.frame.height
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.setNeedsLayout()
        }
    }
    
    @objc func datePickerValueChanged() {
        activeTextField.text = dateFormatter.string(from: datePicker.date)
    }
    
    @IBAction func buttonPressedBook() {
        guard textFieldStartDate.text!.count > 0 else {
            textFieldStartDate.shake()
            
            return
        }
        
        guard textFieldEndDate.text!.count > 0 else {
            textFieldEndDate.shake()
            
            return
        }
        
        viewModel.carBookedPressed(start: dateFormatter.date(from: textFieldStartDate.text!)!, end: dateFormatter.date(from: textFieldEndDate.text!)!)
    }
    
}
