//
//  digorViewController.swift
//  digiBank
//
//  Created by Abhigyan Singh on 17/02/18.
//  Copyright © 2018 DBS. All rights reserved.
//

import UIKit
import Parse
import SwiftyJSON
import LocalAuthentication
import AVFoundation

class DigorViewController: UIViewController, UITextFieldDelegate, RazorpayPaymentCompletionProtocol {

    @IBOutlet weak var digorView: UIView!
    @IBOutlet weak var digorReply: UITextView!
    @IBOutlet weak var inputTF: UITextField!
    
    private var razorpay : Razorpay!
    
    let successFaceAuth: SystemSoundID = 1003
    let sendMessage: SystemSoundID = 1004
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        razorpay = Razorpay.initWithKey("rzp_test_bJ2px5xXNs59hS", andDelegate: self)
        
        inputTF.delegate = self
        digorView.layer.cornerRadius = digorView.frame.size.width/2
        digorView.clipsToBounds = true
        
        digorView.layer.borderColor = UIColor(red: 1, green: 196/255, blue: 36/255, alpha: 1).cgColor
        digorView.layer.borderWidth = 5.0
        inputTF.attributedPlaceholder = NSAttributedString(string: "Ask Anything!",
                                                         attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        let user = PFUser.current()
        if user == nil {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let signInViewController = storyBoard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
            self.present(signInViewController, animated:true, completion:nil)
        } else {
            let installation = PFInstallation.current()
            installation!["user"] = user
            installation?.saveInBackground()
            
            let accountQuery = PFQuery(className: "Account")
            accountQuery.whereKey("user", equalTo: user!)
            accountQuery.getFirstObjectInBackground(block: { (accountObj, error) in
                if error == nil {
                    let balance = accountObj!["balance"]
                    let accountNo = accountObj!["accountNo"]
                    let upi = accountObj!["upi"]
                    self.defaults.set(accountNo!, forKey: "accountNo")
                    self.defaults.set(upi!, forKey: "upi")
                    self.digorReply.text = "Hi! Your current balance is \n₹ \(balance ?? 0.0)"
                }
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        AudioServicesPlaySystemSound (self.sendMessage)
        digorReply.text = "..."
        let digorQuery = inputTF.text
        PFCloud.callFunction(inBackground: "callBot", withParameters: ["digorQuery":digorQuery]) { (result, error) in
            if error == nil {
                self.digorReplyHandler(response: result! as! NSObject)
            } else {
                print(error)
            }
        }
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func digorReplyHandler(response: NSObject) {
        let json = JSON(response)
        switch(json["result"]["metadata"]["intentName"].string) {
        case "payeeIntent"?:
            let payee = json["result"]["parameters"]["payee"].string
            let amount = json["result"]["parameters"]["unit-currency"].string
            if (payee != "" && amount != "") {
                var payeeQuery = PFQuery(className:"Payee")
                payeeQuery.whereKey("user", equalTo: PFUser.current())
                payeeQuery.whereKey("payeeName", equalTo: payee)
                payeeQuery.findObjectsInBackground(block: { (objects, error) in
                    if error == nil {
                        if objects!.count > 0 {
                            let deductAmt = json["result"]["parameters"]["unit-currency"]["amount"].double
                            self.authenticationWithTouchID(reply: json["result"]["fulfillment"]["speech"].string!, amount: deductAmt!)
                            self.inputTF.text = ""
                        } else {
                            self.digorReply.text = "Add \(payee!) to your payees first"
                            self.inputTF.text = ""
                        }
                    }
                })
            } else {
                self.digorReply.text = json["result"]["fulfillment"]["speech"].string
                self.inputTF.text = ""
            }
            break
            
        case "addPayeeIntent"?:
            var upiID = ""
            let pat = "[@][a-z][a-z][a-z]"
            let requestStmt = self.inputTF.text
            let regex = try! NSRegularExpression(pattern: pat, options: [])
            let matches = regex.matches(in: requestStmt!, options: [], range: NSRange(location: 0, length: (requestStmt?.characters.count)!))
            if matches.count == 1 {
                let upiSubStr = requestStmt?.ranges(of: pat, options: .regularExpression).map{requestStmt![$0] }
                let upiStr = Array(upiSubStr!)[0]
                let requestStmtArr = requestStmt?.components(separatedBy: " ")
                for index in requestStmtArr! {
                    if index.range(of: upiStr) != nil {
                        upiID = index
                    }
                }

                let payee = json["result"]["parameters"]["payee"].string
                if payee != "" {
                    let newPayee = PFObject(className: "Payee")
                    newPayee["upi"] = upiID
                    newPayee["user"] = PFUser.current()
                    newPayee["payeeName"] = payee
                    newPayee.saveInBackground(block: { (result, error) in
                        if error == nil {
                            self.digorReply.text = json["result"]["fulfillment"]["speech"].string
                            self.inputTF.text = ""
                        }
                    })
                    
                } else {
                    self.digorReply.text = json["result"]["fulfillment"]["speech"].string
                    self.inputTF.text = ""
                }
            } else {
                self.digorReply.text = "Tell me the UPI"
                self.inputTF.text = ""
            }
            break
        case "addMoney"?:
            let amt = json["result"]["parameters"]["unit-currency"].string
            if amt != "" {
                let amount = json["result"]["parameters"]["unit-currency"]["amount"].doubleValue
                let options = [
                    "amount" : amount*100
                ]
                self.inputTF.text = ""
                let user = PFUser.current()
                let accountQuery = PFQuery(className: "Account")
                accountQuery.whereKey("user", equalTo: user!)
                accountQuery.getFirstObjectInBackground(block: { (accountObj, error) in
                    if error == nil {
                        let balance = accountObj!["balance"] as! Double
                        accountObj!["balance"] = balance + amount
                        accountObj?.saveInBackground()
                    } else {
                        print(error)
                    }
                })
                razorpay.open(options)
            } else {
                self.digorReply.text = json["result"]["fulfillment"]["speech"].string
                self.inputTF.text = ""
            }
            break
        case "balanceIntent"?:
            let user = PFUser.current()
            let accountQuery = PFQuery(className: "Account")
            accountQuery.whereKey("user", equalTo: user!)
            accountQuery.getFirstObjectInBackground(block: { (accountObj, error) in
                if error == nil {
                    let balance = accountObj!["balance"] as! Double
                    self.digorReply.text = "Your balance is\n₹ \(balance)"
                    self.inputTF.text = ""
                }
            })
            break
        case "accountDetailsIntent"?:
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let accountViewController = storyBoard.instantiateViewController(withIdentifier: "AccountViewController") as! AccountViewController
            self.present(accountViewController, animated:true, completion:nil)
            break
        default:
            self.digorReply.text = json["result"]["fulfillment"]["speech"].string
            self.inputTF.text = ""
        }
    }
    
    func onPaymentSuccess(_ payment_id: String) {
        AudioServicesPlaySystemSound (self.successFaceAuth)
        self.digorReply.text = "I have updated your balance"
        
    }
    
    func onPaymentError(_ code: Int32, description str: String) {
        self.digorReply.text = str
    }
    
    func authenticationWithTouchID(reply: String, amount: Double) {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
        
        var authError: NSError?
        let reasonString = "To access the secure data"
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                
                if success {
                    AudioServicesPlaySystemSound (self.successFaceAuth)
                    let user = PFUser.current()
                    let accountQuery = PFQuery(className: "Account")
                    accountQuery.whereKey("user", equalTo: user!)
                    accountQuery.getFirstObjectInBackground(block: { (accountObj, error) in
                        if error == nil {
                            let balance = accountObj!["balance"] as! Double
                            accountObj!["balance"] = balance - amount
                            accountObj?.saveInBackground()
                            DispatchQueue.main.async {
                                self.digorReply.text = "\(reply)\nYour updated balance is\n₹ \(accountObj!["balance"] ?? 0.0)"
                            }
                        }
                    })
                } else {
                    //TODO: User did not authenticate successfully, look at error and take appropriate action
                    guard let error = evaluateError else {
                        return
                    }
                    
                    print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error._code))
                    
                    //TODO: If you have choosen the 'Fallback authentication mechanism selected' (LAError.userFallback). Handle gracefully
                    
                }
            }
        } else {
            
            guard let error = authError else {
                return
            }
            //TODO: Show appropriate alert if biometry/TouchID/FaceID is lockout or not enrolled
            print(self.evaluateAuthenticationPolicyMessageForLA(errorCode: error.code))
        }
    }
    
    func evaluatePolicyFailErrorMessageForLA(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            switch errorCode {
            case LAError.biometryNotAvailable.rawValue:
                message = "Authentication could not start because the device does not support biometric authentication."
                
            case LAError.biometryLockout.rawValue:
                message = "Authentication could not continue because the user has been locked out of biometric authentication, due to failing authentication too many times."
                
            case LAError.biometryNotEnrolled.rawValue:
                message = "Authentication could not start because the user has not enrolled in biometric authentication."
                
            default:
                message = "Did not find error code on LAError object"
            }
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Too many failed attempts."
                
            case LAError.touchIDNotAvailable.rawValue:
                message = "TouchID is not available on the device"
                
            case LAError.touchIDNotEnrolled.rawValue:
                message = "TouchID is not enrolled on the device"
                
            default:
                message = "Did not find error code on LAError object"
            }
        }
        
        return message;
    }
    
    func evaluateAuthenticationPolicyMessageForLA(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
            
        case LAError.authenticationFailed.rawValue:
            message = "The user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was cancelled by application"
            
        case LAError.invalidContext.rawValue:
            message = "The context is invalid"
            
        case LAError.notInteractive.rawValue:
            message = "Not interactive"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was cancelled by the system"
            
        case LAError.userCancel.rawValue:
            message = "The user did cancel"
            
        case LAError.userFallback.rawValue:
            message = "The user chose to use the fallback"
            
        default:
            message = evaluatePolicyFailErrorMessageForLA(errorCode: errorCode)
        }
        
        return message
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

extension String {
    func ranges(of string: String, options: CompareOptions = .literal) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var start = startIndex
        while let range = range(of: string, options: options, range: start..<endIndex) {
            result.append(range)
            start = range.lowerBound < range.upperBound ? range.upperBound : index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}
