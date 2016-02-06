//
//  ViewController.swift
//  SwiftValidateExample
//
//  Created by Danilo Topalovic on 06.02.16.
//  Copyright © 2016 Danilo Topalovic. All rights reserved.
//

import UIKit
import Eureka
import SwiftValidate

class ViewController: FormViewController {

    var validator: ValidationIterator = ValidationIterator()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Evaluate", style: .Plain, target: self, action: Selector("evaluate"))
        
        self.setupForm()
        self.setupFormValidation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func evaluate() {
        
        let formResults = self.form.values()
        let valid = self.validator.validate(formResults)
        
        if !valid {
            
            let errors = self.validator.getAllErrors()
            let msg    = errors.map({ (foo: String, bar: [String]) -> String in
                
                return bar.joinWithSeparator("\n")
            })
            
            
            let alert: UIAlertController = UIAlertController(title: "Form Errors", message: msg.joinWithSeparator("\n"), preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return
        }
        
        let confirm: UIAlertController = UIAlertController(title: "Registration Complete", message: "All OK!", preferredStyle: .Alert)
        confirm.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        self.presentViewController(confirm, animated: true, completion: nil)
    }

    //MARK - SETUP -
    
    /**
    Setups teh form
    */
    private func setupForm() {
        
        self.form
            +++ Section("Mandatory Information")
            <<< NameRow() {
                $0.tag = "firstname"
                $0.title = "Firstname"
            }
            <<< NameRow() {
                $0.tag = "lastname"
                $0.title = "Lastname"
            }
            <<< EmailRow() {
                $0.tag = "emailaddress"
                $0.title = "Email"
            }
            <<< ZipCodeRow() {
                $0.tag = "zipcode"
                $0.title = "Zipcode"
            }
    }
    
    private func setupFormValidation() {
        
        // name, street, city
        self.validator.registerChain(
            ValidatorChain() {
                $0.stopOnException = true
                $0.stopOnFirstError = true
                }
                <~~ ValidatorRequired() {
                    $0.errorMessage = "Please enter Firstname and Lastname"
                }
                <~~ ValidatorEmpty() {
                    $0.errorMessage = "Firstname or Lastname cannot be empty"
                }
                <~~ ValidatorStrLen() {
                    $0.minLength = 3
                    $0.maxLength = 50
                    $0.errorMessageTooLarge = "Firstname and Lastname can have up to 50 chars"
                    $0.errorMessageTooSmall = "Firstname and Lastname need to have at last 3 chars"
            },
            forKeys: ["firstname", "lastname"]
        )
        
        // zipcode
        self.validator.registerChain(
            ValidatorChain() {
                $0.stopOnException = true
                $0.stopOnFirstError = true
                }
                <~~ ValidatorRequired() {
                    $0.errorMessage = "Please enter Zipcode"
                }
                <~~ ValidatorStrLen() {
                    $0.minLength = 5
                    $0.maxLength = 5
                    $0.errorMessageTooLarge = "Zipcode has to have 5 chars"
                    $0.errorMessageTooSmall = $0.errorMessageTooLarge
                }
                <~~ ValidatorNumeric() {
                    $0.allowString = true
                    $0.allowFloatingPoint = false
                    $0.errorMessageNotNumeric = "Zipcode has to be a number"
            },
            forKey: "zipcode"
        )
        
        // email
        self.validator.registerChain(
            ValidatorChain() {
                $0.stopOnException = true
                $0.stopOnFirstError = true
            }
            <~~ ValidatorRequired() {
                $0.errorMessage = "Please enter Emailaddress"
            }
            <~~ ValidatorEmail() {
                $0.errorMessageInvalidAddress = "this is not a valid email address"
            },
            forKey: "emailaddress"
        )
    }
}
