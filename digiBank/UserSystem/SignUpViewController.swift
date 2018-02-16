//
//  SignUpViewController.swift
//  digiBank
//
//  Created by Abhigyan Singh on 15/02/18.
//  Copyright © 2018 DBS. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

class SignUpViewController: UIViewController {
    
    let speechSynthesizer = AVSpeechSynthesizer()

    @IBOutlet weak var chatBotLabel: UILabel!
    
    @IBOutlet weak var fNameTF: UITextField!
    @IBOutlet weak var lNameTF: UITextField!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var mobileTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var aadharTF: UITextField!
    @IBOutlet weak var panTF: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        chatBotLabel.animate(newText: "Hi there! I am Ava.", characterDelay: 0.1)
//        sleep(5000)
//        chatBotLabel.animate(newText: "Your personal digiBank companion.", characterDelay: 0.1)
//        sleep(5000)
//        chatBotLabel.animate(newText: "Lets start by asking your name", characterDelay: 0.1)
        
//        let speechUtterance = AVSpeechUtterance(string: "Hi there! I am ")
//        speechSynthesizer.speak(speechUtterance)
        
        // Do any additional setup after loading the view.
    }

    @IBAction func signupBTN(_ sender: Any) {
        let user = PFUser()
        user.username = usernameTF.text
        user.password = passwordTF.text
        user.email = emailTF.text
        user["firstName"] = fNameTF.text
        user["lastName"] = lNameTF.text
        user["phone"] = Int(mobileTF.text!)
        user["address"] = addressTF.text
        user["aadhar"] = Int(aadharTF.text!)
        user["pan"] = panTF.text
        user.signUpInBackground { (result, error) in
            if error == nil {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let signInViewController = storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                self.present(signInViewController, animated:true, completion:nil)
            } else {
                print(error)
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

extension UILabel {
    
    func animate(newText: String, characterDelay: TimeInterval) {
        
        DispatchQueue.main.async {
            
            self.text = ""
            
            for (index, character) in newText.characters.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + characterDelay * Double(index)) {
                    self.text?.append(character)
                }
            }
        }
    }
    
}
