//
//  HomeViewController.swift
//  digiBank
//
//  Created by Abhigyan Singh on 16/02/18.
//  Copyright © 2018 DBS. All rights reserved.
//

import UIKit
import Cards
import Parse

class HomeViewController: UIViewController {

    @IBOutlet weak var accountCard: CardHighlight!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        
        self.accountCard.backgroundColor = UIColor(red: 1, green: 196/255, blue: 36/255, alpha: 1)
        self.accountCard.icon = UIImage(named: "dbsLogo")
        self.accountCard.hasParallax = true
        
        if PFUser.current() == nil {
            print("Log out")
        } else {
            let user = PFUser.current()
            let accountQuery = PFQuery(className: "Account")
            accountQuery.whereKey("user", equalTo: user!)
            accountQuery.getFirstObjectInBackground(block: { (accountObj, error) in
                if error == nil {
                    let balance = accountObj!["balance"]
                    let accountNo = accountObj!["accountNo"]
                    let upi = accountObj!["upi"]
                    defaults.set(accountNo!, forKey: "accountNo")
                    defaults.set(upi!, forKey: "upi")
                    
                    self.accountCard.title = "Account"
                    self.accountCard.itemTitle = ""
                    self.accountCard.itemSubtitle = ""
                    self.accountCard.buttonText = "₹ \(balance!)"
                } else {
                    self.accountCard.title = "Fetching..."
                    self.accountCard.itemTitle = ""
                    self.accountCard.itemSubtitle = ""
                    self.accountCard.buttonText = String("₹ ...")
                }
            })
            let cardContentVC = storyboard!.instantiateViewController(withIdentifier: "AccountCardContent")
            accountCard.shouldPresent(cardContentVC, from: self, fullscreen: true)
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
