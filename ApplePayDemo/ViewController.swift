//
//  ViewController.swift
//  ApplePayDemo
//
//  Created by Alex Cevallos on 9/26/17.
//  Copyright © 2017 Alex Cevallos. All rights reserved.
//

import UIKit
import PassKit

class ViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var applePayButtonContainer: UIView!
    
    // MARK: Class Variables
    let applePayManager = ApplePayManager()
    
    // MARK: View Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setUpApplePayButton()
    }

    // MARK: Helper Methods
    func setUpApplePayButton() {
        
        let button = PKPaymentButton(type: .buy, style: .black)
        button.addTarget(self, action: #selector(ViewController.applePayButtonPressed), for: .touchUpInside)
        applePayButtonContainer.addSubview(button)
    }
    
    func applePayButtonPressed(sender: AnyObject) {
        
        applePayManager.initiateApplePayScreen() { (wentSuccessful) in
            
            if wentSuccessful {
                
                // ON TO NEXT VIEW!
            }
        }
    }
}

