//
//  SignInViewController.swift
//  digiBank
//
//  Created by Abhigyan Singh on 16/02/18.
//  Copyright © 2018 DBS. All rights reserved.
//

import UIKit
import Parse

class SignInViewController: UIViewController {

    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginBTN(_ sender: Any) {
        PFUser.logInWithUsername(inBackground: usernameTF.text!, password: passwordTF.text!) { (user, error) in
            if error == nil {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let homeViewController = storyBoard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
                self.present(homeViewController, animated:true, completion:nil)
            }
        }
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
