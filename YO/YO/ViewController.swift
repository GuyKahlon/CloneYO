//
//  ViewController.swift
//  YO
//
//  Created by Guy Kahlon on 1/14/15.
//  Copyright (c) 2015 GuyKahlon. All rights reserved.
//

import UIKit

let kRecover : Int = 1
let kLogin   : Int = 2
let kSignup  : Int = 3
let kBack    : Int = 4


extension UIColor{
    
    class func emeraldGreen()-> UIColor{
        return UIColor(red: 30/255, green: 177/255, blue: 137/255, alpha: 1.0)
    }
    
    class func pastelGreen()-> UIColor{
        return UIColor(red: 42/255, green: 197/255, blue: 93/255 , alpha: 1.0)
    }
    
    class func azure()-> UIColor{
        return UIColor(red: 44/255, green: 132/255, blue: 210/255, alpha: 1.0)
    }
    
    class func darkBlue()-> UIColor{
        return UIColor(red: 40/255, green: 56/255 , blue: 75/255 , alpha: 1.0)
    }
    
    class func celadonGreen()-> UIColor{
        return UIColor(red: 25/255, green: 145/255 ,blue: 115/255, alpha: 1.0)
    }
}

class MenuTableViewCell: UITableViewCell{
    @IBOutlet weak var titleTextField: UITextField!
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    @IBOutlet weak var menuButton: UIButton!
    let colors:[UIColor] = [UIColor.emeraldGreen(), UIColor.pastelGreen(), UIColor.azure(), UIColor.darkBlue(), UIColor.celadonGreen()]
    
    var model = Array<(title: String, inputEnable: Bool)>()
    
    let menusModel = MenusModel()
    
    var menuType: MenuType = MenuType.Main {
        willSet(newValue) {
            model = menusModel.getMenu(newValue)
        }
        didSet{
            if menuType.rawValue < oldValue.rawValue{
                tableView?.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Right)
            }
            else{
                tableView?.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Left)
            }
        }
    }
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (PFUser.currentUser() != nil){
           menuType = MenuType.YO
        }
        else{
           menuType = MenuType.Main
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    //MARK: - Private methods
    func clearUsername(){
        if let usernameCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? MenuTableViewCell{
            usernameCell.titleTextField.text = ""
        }
    }
    
    func getUserInputs() -> (username: String?, password: String?, email: String?){
        var inputs = [String?](count: 3, repeatedValue: nil)
        for index in 0...2{
            if let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as? MenuTableViewCell where cell.titleTextField.enabled, let input = cell.titleTextField.text where !input.isEmpty{
                inputs[index] = input
            }
        }
        return (inputs[0], inputs[1], inputs[2])
    }
    
    func userConnected(){
        self.menuType = .YO
    }
    
    func userConnectedFailure(error: NSError){
        
        let errorMsg = error.userInfo![kErrorMessageKey] as! String?
        
        let alert = UIAlertController(title: "Connection Failed", message: errorMsg , preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Dissmis", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func sendYO(){
        if let username = getUserInputs().username{
            ServerUtility.sentYO(username, callbackClosure: { (error: NSError?) -> () in
                if let errorSendYo = error{
                    let errorUserMeesage: String
                    if errorSendYo.code == kUserNotFound{
                        if let errorMsg = errorSendYo.userInfo?[kErrorMessageKey] as! String?{
                            errorUserMeesage = errorMsg
                        }
                        else{
                            errorUserMeesage = "Your YO isn't sent, The username '\(username)' not found"
                        }
                    }
                    else{
                        errorUserMeesage = "There was an error, your YO isn't sent"
                    }
                    var alert = UIAlertController(title: "YO Error", message: errorUserMeesage, preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "Dissmis", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                else{
                    self.clearUsername()
                }
            })
        }
    }
    
    func recoverPassword(){
        var alert = UIAlertController(title: "YO Password Reminder", message: "Please confirm your username and we will send you email for resetting your password.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (alertAction:UIAlertAction!) -> Void in
            
           
            if let textField = alert.textFields?.first as? UITextField{
                ServerUtility.sendResetPasswordMail(textField.text, callbackClosure: { (succeeded, error) -> () in
                    
                    if let errorResetPassword = error {
                        var alert = UIAlertController(title: "YO Error", message: errorResetPassword.userInfo?["user"] as? String, preferredStyle: .Alert)
                        alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    else{
                        self.menuType = .Main
                    }
                })
            }
        }))
        
        alert.addTextFieldWithConfigurationHandler { (textfield: UITextField!) -> Void in
            textfield.text = self.getUserInputs().username
        }
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func login(){
        let (username, password, _) = getUserInputs()
        if let user = username, let pass = password{
            ServerUtility.login(user, password: pass, successClosure:userConnected, failureClosure: userConnectedFailure)
        }
    }
    
    func signup(){
        let (username, password, email) = getUserInputs()
        if let user = username, let pass = password, let userEmail = email  {
            ServerUtility.signUp(user, password: pass,email:userEmail, successClosure: userConnected, failureClosure: userConnectedFailure)
        }
    }
    
    func logout(){
        ServerUtility.logout()
        self.menuType = .Main
    }
}

extension ViewController: UITableViewDelegate{
    
    //MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        switch (menuType, indexPath.row)
        {
        case (.Main, _):
            menuType = MenuType(rawValue: indexPath.row)!
        case (.Signup, kSignup):
            signup()
        case (.Login,kLogin):
            login()
        case (.Recover,kRecover):
            recoverPassword()
        case (.YO,_):
            sendYO()
        default:
            menuType = .Main
        }
    }
    
    //MARK: - IBAction    
    @IBAction func logoutButtonAction(sender: UIButton) {
    
        var actionSheet = UIAlertController(title: "YO Logout", message: "Do you sure you want to log out?", preferredStyle: .ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "Logout", style: UIAlertActionStyle.Destructive, handler: { (alertAction: UIAlertAction!) -> Void in
            self.logout()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource{

    //MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return model.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cellReuseIdentifier", forIndexPath: indexPath) as! MenuTableViewCell
        
        cell.titleTextField.textColor = UIColor.whiteColor()
        cell.titleTextField.enabled = model[indexPath.row].inputEnable
        cell.titleTextField.placeholder = ""
        cell.titleTextField.text = ""
        
        if model[indexPath.row].inputEnable{
            cell.titleTextField.placeholder = model[indexPath.row].title
        }
        else{
            cell.titleTextField.text = model[indexPath.row].title
        }
        
        cell.backgroundColor = colors[indexPath.row]
        return cell;
    }
}

extension ViewController: UITextFieldDelegate{
    
    //MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if string == ""{
            return true
        }
        
        var characterSet:NSCharacterSet = NSCharacterSet(charactersInString: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789@.")

        if ((string as NSString).rangeOfCharacterFromSet(characterSet).location != NSNotFound ){
            
            let start = advance(textField.text.startIndex, range.location)
            let end = advance(start, range.length)
            let textRange = Range<String.Index>(start: start, end: end)
            textField.text = textField.text.stringByReplacingCharactersInRange(textRange, withString: string.uppercaseString)
        }
        
        return false
    }
}