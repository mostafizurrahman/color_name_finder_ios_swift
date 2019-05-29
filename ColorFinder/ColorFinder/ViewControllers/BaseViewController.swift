//
//  BaseViewController.swift
//  ColorFinder
//
//  Created by NoboPay on 29/5/19.
//  Copyright © 2019 Mostafizur Rahman. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    @IBOutlet weak var lockView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        if UserDefaults.standard.bool(forKey: "subscribed") {
            if self.lockView != nil {
                self.lockView.isHidden = true
            }
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func openSubscription(_ sender: Any) {
        self.performSegue(withIdentifier: "SubSegue", sender: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
