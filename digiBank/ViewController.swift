//
//  ViewController.swift
//  digiBank
//
//  Created by Abhigyan Singh on 15/02/18.
//  Copyright © 2018 DBS. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var logoView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoView.layer.borderWidth = 1
        logoView.layer.masksToBounds = false
        logoView.layer.borderColor = UIColor.white.cgColor
        logoView.layer.cornerRadius = logoView.frame.height/2
        logoView.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

