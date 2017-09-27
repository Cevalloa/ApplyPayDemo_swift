//
//  ApplePayManager.swift
//  ApplePayDemo
//
//  Created by Alex Cevallos on 9/26/17.
//  Copyright © 2017 Alex Cevallos. All rights reserved.
//

import Foundation
import PassKit

class ApplePayManager: NSObject {
    
    // MARK: Class Properties
    // Type of cards we accept
    static let creditCardsAccepted: [PKPaymentNetwork] = [
    
        .masterCard,
        .visa
    ]
    
    // Actual modal pop up
    var paymentController: PKPaymentAuthorizationController?
    
    // Individual items to charge
    var paymentSummaryItems = [PKPaymentSummaryItem]()
    
    // Status we return back from our merchant (Sabre)
    var paymentStatus = PKPaymentAuthorizationStatus.failure
    
    // We return this with status of apple pay (success or failure)
    typealias completionAlias = (Bool) -> Void
    var completionClosure: completionAlias?
    
    // MARK: Helper Methods
    // Figure out if this iPhone can handle Apple Payments
    class func canUserPayInApplePay() -> Bool {
        
        return (PKPaymentAuthorizationController.canMakePayments() &&
            PKPaymentAuthorizationController.canMakePayments(usingNetworks:creditCardsAccepted))
    }
    
    // Initiate Payment
    func initiateApplePayScreen(completion: @escaping completionAlias) {
        
        // Create items to charge
        let airFare = PKPaymentSummaryItem(label: "SEA - EWR", amount: NSDecimalNumber(string: "149.99"), type: .final)
        let tax = PKPaymentSummaryItem(label: "Security Tax", amount: NSDecimalNumber(string: "10.00"), type: .final)
        let federalTax = PKPaymentSummaryItem(label: "Federal Tax", amount: NSDecimalNumber(string: "5.00"), type: .final)
        let total = PKPaymentSummaryItem(label: "Alaska Airlines", amount: NSDecimalNumber(string: "164.99"), type: .final)
        
        paymentSummaryItems = [airFare, tax, federalTax, total]
        completionClosure = completion // tells caller success of payment success
        
        // Create Payment Request
        let paymentRequest = PKPaymentRequest()
        paymentRequest.paymentSummaryItems = paymentSummaryItems
        paymentRequest.merchantIdentifier = "will.setup.inDeveloper.portal"
        paymentRequest.merchantCapabilities = .capability3DS // Apple says most use this capability
        paymentRequest.countryCode = "US"
        paymentRequest.currencyCode = "USD"
        paymentRequest.requiredShippingAddressFields = [.phone, .email] // Need from cust?
        paymentRequest.supportedNetworks = ApplePayManager.creditCardsAccepted
        
        // Actually Show Payment Request
        paymentController = PKPaymentAuthorizationController(paymentRequest: paymentRequest)
        paymentController?.delegate = self
        paymentController?.present(completion: { (paymentControllerPresented: Bool) in
            if paymentControllerPresented {
                
                print("Able to show apple pay modal")
            } else {
                
                print("Unable to show apple pay modal")
                self.completionClosure!(false)
            }
        })
        
    }
}

// MARK: Handles Apple Pay responses
extension ApplePayManager: PKPaymentAuthorizationControllerDelegate {
    
    // Called when user taps finger
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didAuthorizePayment payment: PKPayment, completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        
        // Validate contact information
        if payment.shippingContact?.emailAddress == nil || payment.shippingContact?.phoneNumber == nil {
            
            // Throw back to user.. we don't have a way to get in contact!
            paymentStatus = .invalidShippingContact
        } else {
            
            //HERE IS WHERE WE SEND OUR TOKEN TO OUR API, THEN ONTO SABRE
            // ERROR THROWN BACK WILL DETERMINE WHAT WE SEND TO USER
            paymentStatus = .success // temporary!
        }
        
        completion(paymentStatus)
    }
    
    // calls when apple pay controller dismisses
    func paymentAuthorizationControllerDidFinish(_ controller: PKPaymentAuthorizationController) {
        
        controller.dismiss { 
            DispatchQueue.main.async {
                if self.paymentStatus == .success {
                    
                    self.completionClosure!(true)
                } else {
                    
                    self.completionClosure!(false)
                }
            }
        }
    }
    
    func paymentAuthorizationController(_ controller: PKPaymentAuthorizationController, didSelectPaymentMethod paymentMethod: PKPaymentMethod, completion: @escaping ([PKPaymentSummaryItem]) -> Void) {
        
        // Figured I'd put it here.. incase a debit card is used ?
    }
}






