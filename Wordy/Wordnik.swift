//
//  Wordnik.swift
//  Wordy
//
//  Created by Seth Dillingham on 10/3/2015.
//  Copyright © 2015 Macrobyte Resources. All rights reserved.
//

import Foundation

class Wordnik {
    static let api = "http://api.wordnik.com:80/v4"
    static let apiKey = "72567378e90539fc8400d0ca3050fa8f8c08cf14d30f8a7a1"
    
    static var authtok : String?
    static var auth_token : String? {
        get {
            return authtok
        }
        set {
            authtok = newValue
        }
    }
    
    static let paths = [
        "auth": "/account.json/authenticate/{username}",
        "user": "/account.json/user",
        "wordsearch": "/words.json/search/{query}"
    ]
    
    class func apikey() -> String? {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("WordnikAPIKey") as! String?
    }
    
    class func authpath(username : String!) -> String! {
        var path = paths["auth"] as String!
        
        path.replaceRange(path.rangeOfString("{username}")!, with: username)
        
        return path
    }
    
    class func searchpath(word : String!) -> String! {
        var path = paths["wordsearch"] as String!
        
        path.replaceRange(path.rangeOfString("{query}")!, with: word)
        
        return path
    }
}