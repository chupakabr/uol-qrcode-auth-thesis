//
//  EditCredsViewController.swift
//  QrAuthVault
//
//  Created by Valeriy Chevtaev on 03/12/2015.
//  Copyright © 2015 Valera Chevtaev. All rights reserved.
//

import UIKit
import CleanroomLogger

class EditCredsViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO
    }
    
    @IBAction func saveAndLock() {
        // TODO Save
        
        
        // Lock: Go back to main/auth screen
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
