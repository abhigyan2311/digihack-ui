//
//  digorViewController.swift
//  digiBank
//
//  Created by Abhigyan Singh on 17/02/18.
//  Copyright © 2018 DBS. All rights reserved.
//

import UIKit
import Parse

class digorViewController: UIViewController {

    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var inputTF: UITextField!
    
    @IBAction func goBTN(_ sender: Any) {
        var digorQuery = inputTF.text
        PFCloud.callFunction(inBackground: "callBot", withParameters: [:]) { (result, error) in
            if error == nil {
                print(result)
                self.outputLabel.text = result as! String
            } else {
                print(error)
            }
        }
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
//        view.addGestureRecognizer(tap)
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
