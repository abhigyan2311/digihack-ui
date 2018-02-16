//
//  AccountViewController.swift
//  digiBank
//
//  Created by Abhigyan Singh on 17/02/18.
//  Copyright © 2018 DBS. All rights reserved.
//

import UIKit
import Parse

class AccountViewController: UIViewController {

    @IBOutlet weak var upiLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var acNoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = PFUser.current()
        let fName = user!["firstName"]
        let lName = user!["lastName"]
        let upi = UserDefaults.standard.object(forKey: "upi")
        nameLabel.text = "\(fName!) \(lName!)"
        acNoLabel.text = String(UserDefaults.standard.integer(forKey: "accountNo"))
        upiLabel.text = "\(upi!)"
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
