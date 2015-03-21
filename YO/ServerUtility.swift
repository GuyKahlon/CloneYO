//
//  AppDelegate.swift
//  YO
//
//  Created by Guy Kahlon on 1/14/15.
//  Copyright (c) 2015 GuyKahlon. All rights reserved.
//

let kUserNotFound    : Int = 999
let kErrorMessageKey : String = "error"

class ServerUtility {
   
    class func registerUserToPushNotification(){
        
        if let user = PFUser.currentUser(){
            var installation = PFInstallation.currentInstallation()
            installation.setObject(user, forKey: "user")
            installation.saveInBackgroundWithBlock(nil)
        }
    }
    
    class func signUp(username:String, password:String,email: String, successClosure:()->(), failureClosure:(error: NSError) -> ()){
        
        var user = PFUser()
        user.username = username
        user.password = password
        user.email = email
        
        user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError!) -> Void in
            if error == nil {
                successClosure()
                self.registerUserToPushNotification()
            } else {
                failureClosure(error: error)
            }
        }
    }

    class func login(username:String, password:String, successClosure:()->(), failureClosure:(error: NSError) -> ()){
        
        PFUser.logInWithUsernameInBackground(username, password:password) {
            (user: PFUser!, error: NSError!) -> Void in
            if let loginError = error {
                failureClosure(error: error)
            } else {
                successClosure()
                self.registerUserToPushNotification()
            }
        }
    }
    
    class func sentYO(username: String, callbackClosure:(error: NSError?)->()){
        var userQuery = PFUser.query()
        userQuery.whereKey("username", equalTo: username)
        userQuery.findObjectsInBackgroundWithBlock { (users: [AnyObject]!, error: NSError!) -> Void in
            if error != nil {
                callbackClosure(error: error)
            }
            else if users.count < 1{
                callbackClosure(
                    error: NSError(domain: "Send YO",
                    code: kUserNotFound,
                    userInfo: [kErrorMessageKey: "The username '\(username)' not found"]))
            }
            else{                
                // Find devices associated with these users
                let pushInstallationQuery = PFInstallation.query()
                pushInstallationQuery.whereKey("user", matchesQuery: userQuery)
                
                // Send push notification to query
                let push = PFPush()
                push.setQuery(pushInstallationQuery) // Set our Installation query
  
                // Set push notification data
                let data = ["alert" : "YO FROM \(PFUser.currentUser().username)",
                            "sound" : "YO.caf"]
                push.setData(data)
                push.sendPushInBackgroundWithBlock({ (succeeded: Bool, error:NSError!) -> Void in
                    if succeeded{
                        callbackClosure(error: nil)
                    }
                    else{
                        callbackClosure(error: error)
                    }
                })
            }
        }
    }
    
    class func logout(){        
        PFUser.logOut()
    }
    
    class func currentUser() -> PFUser?{
        return PFUser.currentUser()
    }
    
    class func sendResetPasswordMail(username: String, callbackClosure:(succeeded : Bool, error: NSError!)->()){
        
        var userQuery = PFUser.query()
        userQuery.whereKey("username", equalTo: username)
        userQuery.findObjectsInBackgroundWithBlock({ (users: [AnyObject]!, error: NSError!) -> Void in
            
            if let user = users.first as? PFUser where user.email != nil{
                PFUser.requestPasswordResetForEmailInBackground(user.email, block:callbackClosure)
            }
            else{
               callbackClosure(succeeded: false, error: NSError(domain: "ResetPassword", code: kUserNotFound, userInfo: ["user" : "User not found"]))
            }
        })
    }
}