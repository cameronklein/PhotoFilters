//
//  NetworkController.swift
//  TwitterClone
//
//  Created by Cameron Klein on 10/8/14.
//  Copyright (c) 2014 Cameron Klein. All rights reserved.
//

import Foundation
import Accounts
import Social

class NetworkController {
  
  var twitterAccount : ACAccount?
  var cache = [String:UIImage]()
  var authenticatedUserScreenName : String?
  
  init () {
  }

  func postTweet(status : String, image: UIImage, completionHandler : (errorDescription: String?) -> (Void)) {
    println("Network Controller Called!")
    let accountStore = ACAccountStore()
    let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
    
    accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted: Bool, error) -> Void in
      if granted {
        println("Granted!")
        
        let png = UIImagePNGRepresentation(image)
        let accounts = accountStore.accountsWithAccountType(accountType)
        self.twitterAccount = (accounts.first as ACAccount)
        var twitterRequest : SLRequest!
        var paramDictionary = [NSObject : AnyObject]()
        var url : NSURL!
        url = NSURL(string: "https://upload.twitter.com/1/statuses/update_with_media.json")
        twitterRequest = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.POST, URL: url, parameters: ["status" : status])
        twitterRequest.account = self.twitterAccount
        twitterRequest.addMultipartData(png, withName: "media", type: "image/png", filename: "TestImage")
        twitterRequest.performRequestWithHandler({ (data, httpResponse, error) -> Void in
          
          if error == nil {
            println(httpResponse.statusCode)
            
            switch httpResponse.statusCode {
            case 200...299:
              completionHandler(errorDescription: nil)
              println("Posted Tweet!")
            case 400...499:
              completionHandler(errorDescription: "An error occured on your end.")
              println("An error occured on your end.")
            case 500...599:
              completionHandler(errorDescription: "An error occured on Twitter's end.")
              println("An error occured on Twitter's end.")
            default:
              println("Something bad happened: \(error.description)")
            }
          } else {
            println(error.description)
          }
        })
      }
    }
  }
}
  