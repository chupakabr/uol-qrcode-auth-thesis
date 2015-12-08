//
//  ViewController.swift
//  QrAuthVault
//
//  Created by Valeriy Chevtaev on 12/09/2015.
//  Copyright © 2015 Valera Chevtaev. All rights reserved.
//

import UIKit
import CleanroomLogger
import LocalAuthentication

class ViewController: UIViewController {

    var context = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: nil) {
            // TODO Can do auth
        } else {
            // TODO Cannot do auth, display a message on UI
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Reset context so fignerprint is asked again
        context = LAContext()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func authenticate() {
        print("++ authenticate")
        
        // 1.
        if context.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error:nil) {
            
            // 2.
            context.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Logging in with Touch ID",
                reply: { (success : Bool, error : NSError? ) -> Void in
                    
                    // 3.
                    dispatch_async(dispatch_get_main_queue(), {
                        if success {
                            self.performSegueWithIdentifier("auth_done", sender: self)
                        }
                        
                        if error != nil {
                            
                            var message : NSString
                            var showAlert : Bool
                            
                            // 4.
                            switch(error!.code) {
                            case LAError.AuthenticationFailed.rawValue:
                                message = "There was a problem verifying your identity."
                                showAlert = true
                                break;
                            case LAError.UserCancel.rawValue:
                                message = "You pressed cancel."
                                showAlert = true
                                break;
                            case LAError.UserFallback.rawValue:
                                message = "You pressed password."
                                showAlert = true
                                break;
                            default:
                                showAlert = true
                                message = "Touch ID may not be configured"
                                break;
                            }
                            
                            let alertView = UIAlertController(title: "Error",
                                message: message as String, preferredStyle:.Alert)
                            let okAction = UIAlertAction(title: "Darn!", style: .Default, handler: nil)
                            alertView.addAction(okAction)
                            if showAlert {
                                self.presentViewController(alertView, animated: true, completion: nil)
                            }
                            
                        }
                    })
            })
        } else {
            // 5.
            let alertView = UIAlertController(title: "Error", message: "Touch ID not available" as String, preferredStyle:.Alert)
            let okAction = UIAlertAction(title: "Darn!", style: .Default, handler: nil)
            alertView.addAction(okAction)
            self.presentViewController(alertView, animated: true, completion: nil)
        }
        
    }
}

