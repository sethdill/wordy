//
//  WordFieldController.swift
//  Wordy
//
//  Created by Seth Dillingham on 10/3/2015.
//  Copyright © 2015 Macrobyte Resources. All rights reserved.
//

import UIKit

class WordFieldController: NSObject, UITextFieldDelegate {
    
    var field : UITextField!
    var apiTask : NSURLSessionDataTask?
    var lastError : NSError?
    
    dynamic var searchResults = [String]()
    
    required init?(field wordField: UITextField) {
        super.init()
        
        self.field = wordField
        
        self.field.delegate = self
        
        self.lastError = nil
    }
    
    func requestMatchingWords(withString partialWord : String) {
        
        if let oldTask = self.apiTask {
            oldTask.cancel()
            self.apiTask = nil
        }
        
        let path =  Wordnik.searchpath(partialWord)
        let urlComp = NSURLComponents(string: Wordnik.api + path)!
        
        urlComp.queryItems = [
            NSURLQueryItem(name: "api_key", value: Wordnik.apikey())
        ]
        
        let session = NSURLSession.sharedSession()
        let req = NSMutableURLRequest(URL: urlComp.URL!)
        
        req.HTTPMethod = "GET"
        
        let task = session.dataTaskWithURL(urlComp.URL!, completionHandler: {(data, response, error) in
            
            guard let r : NSHTTPURLResponse = response as? NSHTTPURLResponse else {
                print("Request failed, response is nil")
                return
            }
            
            self.lastError = nil
            
            if (r.statusCode == 200 && error == nil) {
                self.parseJsonResults(data, forWord:partialWord)
            }
            else if (r.statusCode != 200) {
                self.searchResults = []
            }
            else if (error != nil) {
                self.searchResults = []
                self.lastError = error
            }
        })
        
        task.resume()
    }
    
    func parseJsonResults(data : NSData?, forWord partialWord:String!) {
        do {
            if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                // let ct : Int = json["totalResults"] as! Int
                var results = [String]()
                
                for wordDict in (json["searchResults"] as! [[String: AnyObject]]) {
                    if (wordDict["count"] as! Int > 0) {
                        results.append(wordDict["word"] as! String)
                    }
                }
                
                self.searchResults = results
            }
        }
        catch {
            print("Query Failed \(partialWord)")
            
            // wait a second and try again
            self.requestMatchingWords(withString: partialWord)
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1000*1000*1), NSURLSession.sharedSession().delegateQueue, { () -> Void in
//                
//            })
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if (newString.characters.count > 2) {
            self.requestMatchingWords(withString: newString)
        }
        else {
            self.searchResults = []
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.field.resignFirstResponder()
        
        return (textField.text!.characters.count >= 3)
    }
}
