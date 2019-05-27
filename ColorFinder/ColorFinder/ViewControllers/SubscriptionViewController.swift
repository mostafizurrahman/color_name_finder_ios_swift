//
//  SubscriptionViewController.swift
//  erica
//
//  Created by Mostafizur Rahman on 25/2/19.
//  Copyright © 2019 Mostafizur Rahman. All rights reserved.
//

import UIKit

import StoreKit
import SwiftyStoreKit


class SubscriptionViewController: UIViewController {
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var buttonBackground: UIView!
    @IBOutlet weak var iconImageView: UIImageView!

    @IBOutlet weak var gradientView: UIView!
    
    @IBOutlet weak var subscribeButton: BorderButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        

        SwiftyStoreKit.retrieveProductsInfo([AppDelegate.SIDF]) { result in

            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                DispatchQueue.main.async {
                    self.priceLabel.text = "monthly \(priceString)/month"
                }
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(result.error)")
            }
        }
        
        subscribeButton.layer.shadowRadius = 12
        subscribeButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        subscribeButton.layer.shadowColor = UIColor.blue.cgColor
        subscribeButton.layer.shadowOpacity = 0.3
        
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.size.width/2
        self.iconImageView.layer.masksToBounds = true
        // Do any additional setup after loading the view.
        
        do {
            guard let filePath = Bundle.main.path(forResource: "terms", ofType: "html")
                else {
                    // File Error
                    print ("File reading error")
                    return
            }
            
            let contents =  try String(contentsOfFile: filePath, encoding: .utf8)
            let baseUrl = URL(fileURLWithPath: filePath)
            webView.loadHTMLString(contents as String, baseURL: baseUrl)
        }
        catch {
            print ("File HTML error")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        var alpha:CGFloat  = 1.0
        for _ in 0...1{
            let gradientLayer = CAGradientLayer()
            gradientLayer.frame = UIDevice.current.userInterfaceIdiom == .pad  ?
                CGRect(origin: .zero, size: CGSize(width: 2000, height: 2000)) : gradientView.layer.bounds
            gradientLayer.colors = [UIColor(white: 1.0, alpha: 0.0).cgColor,
                                    UIColor(white: 1.0, alpha: 1).cgColor]
//            alpha -= 0.15
            self.gradientView.backgroundColor = UIColor.clear
            gradientView.layer.addSublayer(gradientLayer)
        }
        let image = UIImage(named: "ok")
        self.backgroundImage.image = image
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard let layers = self.gradientView.layer.sublayers else {return}
        for layer in Array(layers) {
            layer.frame = self.gradientView.layer.frame
            layer.position = self.gradientView.layer.position
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func exitSubscriptions(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        } else {
            UserDefaults.standard.set(true, forKey: "skip_dismiss")
            self.dismiss(animated: true) {
            
            }
        }
    }
    
    @IBOutlet weak var crossButton: UIButton!
    @IBAction func closeTerms(_ sender: Any) {
        InterfaceHelper.animateOpacity(toInvisible: self.webView, atDuration: 0.4) { (finish) in
            self.crossButton.isHidden = true
        }
    }
    @IBAction func openTersm(_ sender: Any) {
        InterfaceHelper.animateOpacity(toVisible: self.webView, atDuration: 0.4) { (finish) in
            self.crossButton.isHidden = false
            self.view.bringSubviewToFront(self.crossButton)
        }
    }
    
    @IBAction func restorePurchase(_ sender: Any) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                for product in results.restoredPurchases {
                    if product.productId.elementsEqual(AppDelegate.SIDF){
                        
                        UserDefaults.standard.set(product.productId, forKey: "subs")
                        UserDefaults.standard.set(true, forKey: "ad_removed")
                        
                        UserDefaults.standard.synchronize()
                        DispatchQueue.main.async {
                            if UserDefaults.standard.bool(forKey: "ad_removed"){
                                print("+++++++++++++++++done")
                            }
                            NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "remove_ad_notification")))
                            self.dismiss(animated: true
                                , completion: {
                                    
                            })
                        }
                        
                    }
                }
            }
            else {
                print("Nothing to Restore")
            }
        }
    }
    
    @IBAction func buySubscriptions(_ sender: Any) {
        self.loadingView.isHidden = false
        self.purchaseSubscription(ProductID: AppDelegate.SIDF)
    }
    
    
    func getReceipt(){
        SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
            switch result {
            case .success(let receiptData):
                let encryptedReceipt = receiptData.base64EncodedString(options: [])
                print("Fetch receipt success:\n\(encryptedReceipt)")
                UserDefaults.standard.setValue(encryptedReceipt, forKey: "PurchaseReceipt")
            case .error(let error):
                print("Fetch receipt failed: \(error)")
            }
        }
    }
    
    func validateReceipt(){
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: AppDelegate.SS)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { result in
            switch result {
            case .success(let receipt):
                print("Verify receipt success: \(receipt)")
            case .error(let error):
                print("Verify receipt failed: \(error)")
            }
        }
    }
    
    func varifySubscription(Product productId: String){
       
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: AppDelegate.SS)

        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                
                // Verify the purchase of Consumable or NonConsumable
                let purchaseResult = SwiftyStoreKit.verifyPurchase(
                    productId: productId,
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased(let receiptItem):
                    print("\(productId) is purchased: \(receiptItem)")
                    
                    UserDefaults.standard.set(true, forKey: "ad_removed")
                    UserDefaults.standard.synchronize()
                    NotificationCenter.default.post(Notification.init(name:
                        Notification.Name(rawValue: "remove_ad_notification")))
                    
                    DispatchQueue.main.async {
                        self.loadingView.isHidden = true
                        self.dismiss(animated: true, completion: {
                            
                        })
                    }
                    
                    
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                    DispatchQueue.main.async {
                        self.loadingView.isHidden = true
                    }
                    //show alert for purchase error
                }
            case .error(let error):
                DispatchQueue.main.async {
                    self.loadingView.isHidden = true
                }
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    func purchaseSubscription(ProductID productID:String){
        SwiftyStoreKit.purchaseProduct(productID, atomically: true) { result in
            print(result)
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: AppDelegate.SS)

                SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                    
                    if case .success(let receipt) = result {
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            ofType: .autoRenewable,
                            productId: productID,
                            inReceipt: receipt)
                        
                        switch purchaseResult {
                        case .purchased(let expiryDate, let receiptItems):
                            print("Product is valid until \(expiryDate)")
                            
                            self.varifySubscription(Product: productID)
                        case .expired(let expiryDate, let receiptItems):
                            DispatchQueue.main.async {
                                self.loadingView.isHidden = true
                            }
                            print("Product is expired since \(expiryDate)")
                        case .notPurchased:
                            DispatchQueue.main.async {
                                self.loadingView.isHidden = true
                            }
                            print("This product has never been purchased")
                        }
                        
                    } else {
                        DispatchQueue.main.async {
                            self.loadingView.isHidden = true
                        }
                        // receipt verification error
                    }
                }
            } else {
                
                let avc = UIAlertController(title: "Unable to purchase",
                                            message: "Cannot connect to iTunes Store.",
                                            preferredStyle: .actionSheet)
                if let pop = avc.popoverPresentationController {
                    pop.permittedArrowDirections = []
                    pop.sourceView = self.view
                    pop.sourceRect = CGRect(origin: CGPoint(x: self.view.frame.midX, y: self.view.frame.midY), size: .zero)
                }
                let action = UIAlertAction(title: "Done", style: .default, handler: { (_) in
                   
                })
                    avc.addAction(action)
                    
                    
                DispatchQueue.main.async {
                    self.present(avc, animated: true, completion: {
                        
                    })
                    self.loadingView.isHidden = true
                }
                // purchase error
            }
        }
    }
}
