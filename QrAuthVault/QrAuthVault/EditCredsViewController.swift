//
//  EditCredsViewController.swift
//  QrAuthVault
//
//  Created by Valeriy Chevtaev on 03/12/2015.
//  Copyright © 2015 Valera Chevtaev. All rights reserved.
//

import UIKit
import CleanroomLogger
import QRCodeReader
import AVFoundation
import Alamofire
import CryptoSwift

class EditCredsViewController: UIViewController {

    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var scannedQrText: UITextView!
    
    //AVMetadataObjectTypeQRCode
    lazy var reader = QRCodeReaderViewController(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO
    }
    
    // MARK: - UI actions
    
    @IBAction func scan() {
        print("++ TODO scan QR")
        
        // Or by using the closure pattern
        reader.completionBlock = { [weak self] (result: String?) in
            defer {
                if let vc = self {
                    vc.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            if let result = result {
                print("Raw QR JSON: \(result)")
                
                let data: NSData = result.dataUsingEncoding(NSUTF8StringEncoding)!
                var json: AnyObject? = nil
                do {
                    try json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
                    
                    if let json = json, seq = json["seq"] as! String?, url = json["url"] as! String?, ts = json["ts"] as! Int? {
                        print("Parsed: seq=[\(seq)], url=[\(url)], ts=[\(ts)]")
                        if let vc = self {
                            try vc.onSuccess(seq: seq, url: url, timestamp: ts)
                        }
                    } else {
                        throw NSError(domain: "Unable to parse JSON", code: 1, userInfo: nil)
                    }
                    
                } catch {
                    // error parsing JSON
                    print("ERROR QR JSON parsing: \(error)")
                    
                    // Alert: parsing error
                    if let vc = self {
                        vc.onError(message: "Cannot parse QR")
                    }
                }
            } else {
                // Alert: nothing in QR code
                print("QR JSON is empty or cancel pressed")
                if let vc = self {
                    vc.onError(message: "Scan cancelled")
                }
            }
        }
        
        // Presents the reader as modal form sheet
        reader.modalPresentationStyle = .FormSheet
        presentViewController(reader, animated: true, completion: nil)
    }
    
    @IBAction func save() {
        print("++ save")
        saveCredentials()
    }
    
    @IBAction func saveAndLock() {
        print("++ save and lock")
        
        // Save
        saveCredentials()
        
        // Lock: Go back to main/auth screen
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //
    // Save credentials to the vault
    private func saveCredentials() {
        // TODO
        print("TODO save credentials")
    }
    
    //
    // Handle QR parsing success
    private func onSuccess(seq seq: String?, url: String?, timestamp ts: Int?) throws {
        print("onSuccess: seq=[\(seq)], url=[\(url)], ts=[\(ts)]")
        guard let url = url, ts = ts, seq = seq else {
            throw NSError(domain: "Empty parameters on success", code: 2, userInfo: nil)
        }
        
        // Calculate md5 of seq+ts to product ID
        let id = "\(seq)\(ts)".md5()
        
        // Success: update UI
        dispatch_async(dispatch_get_main_queue()) {
            [weak self] in
            if let vc = self {
                vc.scannedQrText.text = "id=\(id)\nurl=\(url)\nts=\(ts)"
            }
        }
        
        // Success: upload credentials file
        do {
            try uploadCredentials(id: id, loginInfo: loadCredentials(url), timestamp: ts)
        } catch {
            // TODO Handle error
            print("ERROR Can't upload credentials: \(error)")
        }
    }

    //
    // Handle QR parsing error
    private func onError(message error: String) {
        // TODO Alert?
        print("ERROR \(error)")
    }

    //
    // Upload user credentials to file sharing service
    // TODO Use SSL!!! (HTTPS)
    private func uploadCredentials(id id: String?, loginInfo: LoginInfo?, timestamp ts: Int?, lifetimeSec ttlSec: Int = 120) throws {
        guard let loginInfo = loginInfo, id = id, ts = ts else {
            throw NSError(domain: "Login information, id or timestamp not found", code: 1, userInfo: nil)
        }
        
        let dataStr = "\(id):\(ts):\(loginInfo.username):\(loginInfo.password)"
        print("Upload credentials: \(dataStr)")
        
        if let data = dataStr.dataUsingEncoding(NSUTF8StringEncoding) {
            Alamofire.upload(.PUT,
                "http://chupakabr.ru/extra-test-qr-api/methods/put.php",
                data: data)
        } else {
            print("ERROR cannot serialize credentials upload")
        }
    }
    
    //
    // Load user credentials for specified URL from the vault
    private func loadCredentials(url: String) -> LoginInfo? {
        if let username = usernameTextField.text, password = passwordTextField.text {
            return LoginInfo(service: "google", username: username, password: password)
        }
        return nil
    }
}

//
// Login information plain immutable object
class LoginInfo {
    let service: String
    let username: String
    let password: String
    
    init(service: String, username: String, password: String) {
        self.service = service
        self.username = username
        self.password = password
    }
}
