//
//  ApplePayManager.swift
//  ApplePayDemo
//
//  Created by Alex Cevallos on 9/26/17.
//  Copyright © 2017 Alex Cevallos. All rights reserved.
//

import Foundation
import PassKit

class ApplePayManager {
    
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
    var completion: completionAlias?
    
    // MARK: Helper Methods
    // Figure out if this iPhone can handle Apple Payments
    class func canUserPayInApplePay() -> Bool {
        
        return (PKPaymentAuthorizationController.canMakePayments() &&
            PKPaymentAuthorizationController.canMakePayments(usingNetworks:creditCardsAccepted))
    }
    
    // Initiate Payment
    func initiateApplePayScreen() {
        
        // Create items to charge
        let airFare = PKPaymentSummaryItem(label: "SEA - EWR", amount: NSDecimalNumber(string: "149.99"), type: .final)
        let tax = PKPaymentSummaryItem(label: "Security Tax", amount: NSDecimalNumber(string: "10.00"), type: .final)
        let federalTax = PKPaymentSummaryItem(label: "Federal Tax", amount: NSDecimalNumber(string: "5.00"), type: .final)
        let total = PKPaymentSummaryItem(label: "Alaska Airlines", amount: NSDecimalNumber(string: "164.99"), type: .pending)
        
        paymentSummaryItems = [airFare, tax, federalTax, total]
        
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
        
    }
}








