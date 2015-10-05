//
//  ViewController.swift
//  Wordy
//
//  Created by Seth Dillingham on 10/3/2015.
//  Copyright © 2015 Macrobyte Resources. All rights reserved.
//

import UIKit

typealias KVOContext = UInt8
var SearchResultsObserverContext = KVOContext()
var WordFieldErrorObserverContext = KVOContext()

class ViewController: UIViewController {
    
    @IBOutlet weak var wordField : UITextField!
    var fieldController : WordFieldController!
    
    @IBOutlet weak var resultsTableView: UITableView!
    
    @IBOutlet weak var authTokenLabel : UILabel!
    
    var loggedIn = false
    
    let keychainWrapper = KeychainWrapper()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.fieldController = WordFieldController(field: self.wordField)
        
        self.fieldController.addObserver(self, forKeyPath: "searchResults", options: NSKeyValueObservingOptions([.New]), context: &SearchResultsObserverContext)
        
        self.fieldController.addObserver(self, forKeyPath: "lastError", options: NSKeyValueObservingOptions([.New]), context: &WordFieldErrorObserverContext)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if (!self.loggedIn) {
            self.login()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didLogIn() {
        self.wordField.enabled = true;
    }
    
    func didLogOut() {
        self.wordField.enabled = false;
    }
    
    func alert(title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func requestCredentials() {
        let alert = UIAlertController(title: "Wordnik", message: "Log in to Wordnik", preferredStyle: .Alert)
        
        let loginAction = UIAlertAction(title: "Login", style: .Default, handler: { (_) -> Void in
            let userTextField = alert.textFields![0] as UITextField
            let passTextField = alert.textFields![1] as UITextField
            
            self.keychainWrapper.mySetObject(passTextField.text, forKey: kSecValueData)
            self.keychainWrapper.writeToKeychain()
            
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasAccount")
            NSUserDefaults.standardUserDefaults().setValue(userTextField.text, forKey: "username")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            self.login()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (_) -> Void in })
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Login"
            
            NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object: textField, queue: NSOperationQueue.mainQueue(), usingBlock: { (notification) -> Void in
                loginAction.enabled = textField.text != ""
            })
        })
        
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        })
        
        alert.addAction(loginAction)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func login() {
        if (self.loggedIn) {
            return
        }
        
        let hasAccount = NSUserDefaults.standardUserDefaults().boolForKey("hasAccount")
        if (!hasAccount) {
            return self.requestCredentials()
        }
            
        let username : String = NSUserDefaults.standardUserDefaults().stringForKey("username")!
        let password : String? = self.keychainWrapper.myObjectForKey("v_Data") as? String
        
        let path =  Wordnik.authpath(username)
        let urlComp = NSURLComponents(string: Wordnik.api + path)!
        
        urlComp.queryItems = [
            NSURLQueryItem(name: "password", value: password),
            NSURLQueryItem(name: "api_key", value: Wordnik.apikey())
        ]
        
        let session = NSURLSession.sharedSession()
        let req = NSMutableURLRequest(URL: urlComp.URL!)
        
        req.HTTPMethod = "GET"
        
        let task = session.dataTaskWithURL(urlComp.URL!, completionHandler: {(data, response, error) in
            
            let r : NSHTTPURLResponse = response as! NSHTTPURLResponse
            
            if (r.statusCode == 200 && error == nil) {
                do {
                    if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                        Wordnik.auth_token = json["token"] as! String!
                        self.didLogIn()
                        
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            self.authTokenLabel.text = "Auth: \(Wordnik.auth_token!)"
                            self.authTokenLabel.setNeedsDisplay()
                        })
                    }
                }
                catch {
                    NSLog("Logon Failed")
                    
                    self.alert("Logon Failed", message: "An error prevented app from logging on. Bad resposne from the server. I'll keep trying!")
                    
                    // wait a second and try again
                    // this is lame but it's good enough for a demo :p
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1000*1000*1), dispatch_get_main_queue(), { () -> Void in
                        self.login()
                    })
                }
            }
        })
        
        task.resume()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard keyPath != nil else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
            return
        }
        
        switch (keyPath!, context) {
        case("searchResults", &SearchResultsObserverContext):
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.reload()
            })
            
        case("lastError", &WordFieldErrorObserverContext):
            if let lastError = self.fieldController.lastError {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.alert("Error (Debug)", message: lastError.localizedDescription)
                })
            }
            
        default:
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }
    
    func reload() {
        self.resultsTableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fieldController.searchResults.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.resultsTableView.dequeueReusableCellWithIdentifier("wordCell", forIndexPath: indexPath) as! WordTableViewCell
        
        if let label : UILabel = cell.wordLabel {
            label.text = self.fieldController.searchResults[indexPath.row]
            label.backgroundColor = UIColor.clearColor()
        }
        
        return cell
    }
}

extension ViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.alert(self.fieldController.searchResults[indexPath.row], message: "I suppose this should present the definition or synonyms or whatever. This is enough demo, though.")
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}