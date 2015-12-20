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
import CoreData
import JavaScriptCore

class EditCredsViewController: UIViewController {

    // TODO Use SSL!!! (HTTPS)
    private let fileShareUrl = "https://chupakabr.ru/extra-test-qr-api/methods/put.php"
    private let defaultLoginUrl = "https://accounts.google.com/AddSession"
    private let defaultService = "google"
    
    private var jsContext: JSContext! = nil
    
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var scannedQrText: UITextView!
    
    lazy var reader = QRCodeReaderViewController(metadataObjectTypes: [AVMetadataObjectTypeQRCode])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load credentials from data store
        let savedModel = loadEntry(defaultService)
        if let savedModel = savedModel {
            self.usernameTextField.text = savedModel.usr
            self.passwordTextField.text = savedModel.pwd
        }
        
        print("Unlocked!")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Load JS libraries into JS context
        if jsContext == nil {
            do {
                jsContext = JSContext()
                try jsContext.evaluateScript(String(contentsOfURL: jsFile("core"), encoding: NSUTF8StringEncoding))
                try jsContext.evaluateScript(String(contentsOfURL: jsFile("enc-base64"), encoding: NSUTF8StringEncoding))
                try jsContext.evaluateScript(String(contentsOfURL: jsFile("md5"), encoding: NSUTF8StringEncoding))
                try jsContext.evaluateScript(String(contentsOfURL: jsFile("evpkdf"), encoding: NSUTF8StringEncoding))
                try jsContext.evaluateScript(String(contentsOfURL: jsFile("cipher-core"), encoding: NSUTF8StringEncoding))
                try jsContext.evaluateScript(String(contentsOfURL: jsFile("aes"), encoding: NSUTF8StringEncoding))
                try jsContext.evaluateScript(String(contentsOfURL: jsFile("BigInt"), encoding: NSUTF8StringEncoding))
                try jsContext.evaluateScript(String(contentsOfURL: jsFile("qrvault-crypto"), encoding: NSUTF8StringEncoding))
                
                print("JS loaded")
            } catch let err as NSError {
                // Go back to main/auth screen
                print("ERROR Cannot load JS scripts: \(err)")
                self.dismissViewControllerAnimated(animated, completion: nil)
                return
            }
        }
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
                    
                    if let json = json,
                        seq = json["seq"] as! String?,
                        url = json["url"] as! String?,
                        ts = json["ts"] as! Int?,
                        dhP = json["dhP"] as! String?,
                        dhG = json["dhG"] as! String?,
                        dhKey = json["dhKey"] as! String?
                    {
                        let dhInfo = DhInfo(p: dhP, g: dhG, key: dhKey)
                        print("Parsed: seq=[\(seq)], url=[\(url)], ts=[\(ts), dh=[\(dhInfo)]]")
                        if let vc = self {
                            try vc.onSuccess(seq: seq, url: url, timestamp: ts, dh: dhInfo)
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
        
        do {
            try saveCredentials()
        } catch let err as NSError {
            print("ERROR Cannot persist credentials to database: \(err)")
        }
    }
    
    @IBAction func saveAndLock() {
        print("++ lock")
        
        // Save
        do {
            try saveCredentials()
        } catch let err as NSError {
            print("ERROR Cannot persist credentials to database: \(err)")
        }
        
        // Lock: Go back to main/auth screen
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //
    // Save credentials to the vault
    // TODO Perform on background thread
    private func saveCredentials() throws {
        print("saving credentials...")
        
        let credentials = loadCredentials(defaultLoginUrl)
        guard let credentialsGuarded = credentials else {
            throw NSError(domain: "Cannot read credentials", code: 1, userInfo: nil)
        }
        
        // try to load existing entry in DB first
        var model = loadEntry(credentialsGuarded.service)
        if model == nil {
            model = Credential(entity: getDataEntity(), insertIntoManagedObjectContext: getMOC())
        }
        model!.usr = credentialsGuarded.username
        model!.pwd = credentialsGuarded.password
        model!.service = credentialsGuarded.service
        model!.save()
    }
    
    //
    // Handle QR parsing success
    private func onSuccess(seq seq: String?, url: String?, timestamp ts: Int?, dh: DhInfo) throws {
        print("onSuccess: seq=[\(seq)], url=[\(url)], ts=[\(ts)], \(dh)")
        guard let url = url, ts = ts, seq = seq else {
            throw NSError(domain: "Empty parameters on success", code: 2, userInfo: nil)
        }
        
        // Calculate md5 of seq+ts to produce ID
        let id = "\(seq)\(ts)".md5()
        
        // Success: update UI
        dispatch_async(dispatch_get_main_queue()) {
            [weak self] in
            if let vc = self {
                vc.scannedQrText.text = "id=\(id)\nurl=\(url)\nts=\(ts)\nDiffie-Hellman: \(dh)"
            }
        }
        
        // Success: upload credentials file
        do {
            try uploadCredentials(id: id, loginInfo: loadCredentials(url), timestamp: ts, dh: dh)
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
    private func uploadCredentials(id id: String?, loginInfo: LoginInfo?,
        timestamp ts: Int?, dh: DhInfo, lifetimeSec ttlSec: Int = 120) throws
    {
        guard let loginInfo = loginInfo, id = id, ts = ts else {
            throw NSError(domain: "Login information, id or timestamp not found", code: 1, userInfo: nil)
        }
        
        // Generate local secret, public and shared keys
        let secret = genSecretKey()
        let publicB = evalPublicKey(g: dh.g, secret: secret, p: dh.p)
        let sharedKey = evalSharedPrivateKey(publicA: dh.pubKey, secret: secret, p: dh.p)
        let cipher = encryptMessage("\(loginInfo.username):\(loginInfo.password)", sharedKey: sharedKey)
        print("secret=\(secret)")
        print("publicB=\(publicB)")
        print("sharedKey=\(sharedKey)")
        print("cipher=\(cipher)")
        
        // Encrypt data with shared key
        let dataStr = "\(id):\(ts):\(publicB):\(cipher)"
        print("Upload credentials: \(dataStr)")
        
        if let data = dataStr.dataUsingEncoding(NSUTF8StringEncoding) {
            print("Uploading encrypted credentials to \(fileShareUrl)")
            Alamofire.upload(.PUT, fileShareUrl, data: data)
        } else {
            print("ERROR cannot serialize credentials upload")
        }
    }
    
    //
    // Load user credentials for specified URL from the vault
    // TODO Evaluate service using URL passed as parameter
    private func loadCredentials(url: String) -> LoginInfo? {
        if let username = usernameTextField.text, password = passwordTextField.text {
            return LoginInfo(service: defaultService, username: username, password: password)
        }
        return nil
    }
    
    
    //
    // MARK: - Database operations
    
    private func getSharedDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    private func getMOC() -> NSManagedObjectContext {
        return getSharedDelegate().managedObjectContext
    }
    
    private func getDataEntity() -> NSEntityDescription {
        // cannot be nil
        return NSEntityDescription.entityForName("Credential", inManagedObjectContext: getMOC())!
    }
    
    private func loadEntry(service: String) -> Credential? {
        let fetchRequest = NSFetchRequest(entityName: "Credential")
        fetchRequest.predicate = NSPredicate(format: "service == %@", service)
        do {
            let res = try getMOC().executeFetchRequest(fetchRequest)
            if res.count > 0 {
                return res[0] as? Credential
            }
        } catch let err as NSError {
            print("ERROR Cannot load entries from database: \(err)")
        }
        
        return nil
    }
    

    //
    // MARK: - JS manipulation and evaluation

    private func jsFile(filenameWithoutExt: String) throws -> NSURL {
        guard let file = NSBundle.mainBundle().URLForResource(filenameWithoutExt, withExtension: "js", subdirectory: "js") else {
            throw NSError(domain: "JsFileLoad", code: 1, userInfo: ["file": filenameWithoutExt])
        }
        return file
    }
    
    private func genSecretKey() -> String {
        let secret: JSValue = jsContext.evaluateScript("qrauth.crypto.bigint2str(qrauth.crypto.genSecret())")
        return secret.toString()
    }
    
    private func evalPublicKey(g g: String, secret: String, p: String) -> String {
        let jsFuncEvalPubKey = getJsCryptoFunc("evalPubKeyFromStr")
        let publicKey: JSValue = jsFuncEvalPubKey.callWithArguments([g, secret, p])
        return publicKey.toString()
    }
    
    private func evalSharedPrivateKey(publicA publicA: String, secret: String, p: String) -> String {
        let jsFunc = getJsCryptoFunc("evalPrivKeyFromStr")
        let privateKey: JSValue = jsFunc.callWithArguments([publicA, secret, p])
        return privateKey.toString()
    }

    private func encryptMessage(text: String, sharedKey: String) -> String {
        let jsFunc = getJsCryptoFunc("encrypt")
        let cipher: JSValue = jsFunc.callWithArguments([text, sharedKey])
        return cipher.toString()
    }
    
    private func getJsCryptoFunc(funcName: String) -> JSValue! {
        return jsContext.objectForKeyedSubscript("qrauth").objectForKeyedSubscript("crypto").objectForKeyedSubscript(funcName)
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

//
// Diffie-Hellman information holder
class DhInfo: CustomStringConvertible {
    let p: String
    let g: String
    let pubKey: String
    
    init(p: String, g: String, key: String) {
        self.p = p;
        self.g = g;
        self.pubKey = key;
    }
    
    var description: String {
        return "DH(p=\(p),g=\(g),pubKey=\(pubKey))"
    }
}

