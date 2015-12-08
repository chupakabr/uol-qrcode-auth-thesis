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
                    
                    if let json = json, url = json["url"] as! String?, ts = json["ts"] as! Int? {
                        print("Parsed: url=[\(url)], ts=[\(ts)]")
                        if let vc = self {
                            try vc.onSuccess(url: url, timestamp: ts)
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
    
    private func saveCredentials() {
        // TODO
        print("TODO save credentials")
    }
    
    private func onSuccess(url url: String?, timestamp ts: Int?) throws {
        print("onSuccess: url=[\(url)], ts=[\(ts)]")
        guard let url = url, ts = ts else {
            throw NSError(domain: "Empty parameters on success", code: 2, userInfo: nil)
        }
        
        // Success: update UI
        dispatch_async(dispatch_get_main_queue()) {
            [weak self] in
            if let vc = self {
                vc.scannedQrText.text = "url=\(url)\nts=\(ts)"
            }
        }
        
        // TODO Success: upload credentials file
        
    }
    
    private func onError(message error: String) {
        // TODO Alert?
        print("ERROR \(error)")
    }
}
