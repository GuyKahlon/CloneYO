//
//  ViewController.swift
//  YO
//
//  Created by Guy Kahlon on 1/14/15.
//  Copyright (c) 2015 GuyKahlon. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell{
    @IBOutlet weak var titleTextField: UITextField!
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    enum MenuType: Int{
        case Signup = 0 ,Login = 1,  Recover = 2, Main = 10, YO
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    let main   :Array<(title: String, inputEnable: Bool)> = [("SIGNUP",false),("LOGIN",false),("RECOVER PASS",false)]
    let signup :Array<(title: String, inputEnable: Bool)> = [("CHOOSE USERNAME",true),("CHOOSE PASSCODE",true),("ENTER EMAIL",true),("TAP TO SIGNUP",false),("GO BACK",false)]
    let login  :Array<(title: String, inputEnable: Bool)> = [("USERNAME",true),("PASSCODE",true),("TAP TO LOGIN",false),("GO BACK",false)]
    let recover:Array<(title: String, inputEnable: Bool)> = [("USERNAME",true),("TAP TO RECOVER",false),("GO BACK",false)]
    let sendYo :Array<(title: String, inputEnable: Bool)> = [("USERNAME",true),("TAP TO YO",false)]
    
    var model = Array<(title: String, inputEnable: Bool)>()
    
    let colors:Array<UIColor> = [UIColor(red: 30/255, green: 177/255, blue: 137/255, alpha: 1.0),
                                 UIColor(red: 42/255, green: 197/255, blue: 93/255 , alpha: 1.0),
                                 UIColor(red: 44/255, green: 132/255, blue: 210/255, alpha: 1.0),
                                 UIColor(red: 40/255, green: 56/255 , blue: 75/255 , alpha: 1.0),
                                 UIColor(red: 25/255, green: 145/255 ,blue: 115/255, alpha: 1.0)]
    
    var menuType = MenuType.Main
    
    //pragma mark: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        model = main
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    //pragma mark: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return model.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cellReuseIdentifier", forIndexPath: indexPath) as MenuTableViewCell
        
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
    
    //pragma mark: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        switch menuType
        {
            case .Main:
                mainMenuHandle(indexPath)
            case .Signup:
                signupMenuHandle(indexPath)
            case .Login:
                loginMenuHandle(indexPath)
            case .Recover:
                recoverMenuHandle(indexPath)
            case .YO:
                yoMenuHandle(indexPath)
            default:
                println("kajshd")
        }
    }
    
    //pragma mark: - Private method
    func mainMenuHandle(indexPath: NSIndexPath){
        
        switch indexPath.row{
        
            case 0 ://signup
                menuType = .Signup
                model = signup
                tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Left)
            case 1://login
                menuType = .Login
                model = login
                tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Left)
            case 2://recover
                menuType = .Recover
                model = recover
                tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Left)
            default:
                menuType = .Main
                model = main
        }
    }
    
    func signupMenuHandle(indexPath: NSIndexPath){
        
        switch indexPath.row{
        case 3://Tap To signup
           println("Tap tp signup")
           //Todo - Call to parse sign up.
//           let successClosure:()->() = {
//            
//           }
//
//           var failureClosure: (error:NSError) -> () = {
//            
//           }
           
           let usernameCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as MenuTableViewCell
           let passwordCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as MenuTableViewCell
          
           let username = usernameCell.titleTextField.text
           let password = passwordCell.titleTextField.text
           
           if !username.isEmpty && !password.isEmpty{
                self.signUp(usernameCell.titleTextField.text, password: passwordCell.titleTextField.text, successClosure: { () -> () in
                    
                    self.menuType = .YO
                    self.model = self.sendYo
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Left)
                    
                    }, failureClosure: { (error) -> () in
                        println("\(error)")
                })
           }
        case 4://Back
            menuType = .Main
            model = main
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Right)
        default:
            menuType = .Main
            model = main
        }
    }
    
    func loginMenuHandle(indexPath: NSIndexPath){
        
        switch indexPath.row{
        case 2://login
            
            let usernameCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as MenuTableViewCell
            let passwordCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0)) as MenuTableViewCell
            
            let username = usernameCell.titleTextField.text
            let password = passwordCell.titleTextField.text
            
            if !username.isEmpty && !password.isEmpty{
                self.login(usernameCell.titleTextField.text, password: passwordCell.titleTextField.text, successClosure: { () -> () in
                    
                    self.menuType = .YO
                    self.model = self.sendYo
                    self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Left)
                    
                    }, failureClosure: { (error) -> () in
                        println("\(error)")
                })
            }
            
        case 3://Back
            menuType = .Main
            model = main
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Right)
        default:
            menuType = .Main
            model = main
        }
    }
    
    func recoverMenuHandle(indexPath: NSIndexPath){
        
        switch indexPath.row{
        case 1://Tap to recover
            let usernameCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as MenuTableViewCell
            println("\(usernameCell.titleTextField.text)")
        case 2://Back
            menuType = .Main
            model = main
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Right)
        default:
            menuType = .Main
            model = main
        }
    }
    
    func yoMenuHandle(indexPath: NSIndexPath){
        
        switch indexPath.row{
        case 1://send yo
            menuType = .Main
            model = main
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Right)
        default:
            println("")
        }
    }
    
    func login(username:String, password:String, successClosure:()->(), failureClosure:(error: NSError) -> ()){
        
        PFUser.logInWithUsernameInBackground(username, password:password) {
            (user: PFUser!, error: NSError!) -> Void in
            if user != nil {
                successClosure()
            } else {
                failureClosure(error: error)
            }
        }
    }
    
    func signUp(username:String, password:String, successClosure:()->(), failureClosure:(error: NSError) -> ()){
        
        var user = PFUser()
        user.username = username
        user.password = password
        user.signUpInBackgroundWithBlock {
            (succeeded: Bool!, error: NSError!) -> Void in
            if error == nil {
                successClosure()
            } else {
                failureClosure(error: error)
            }
        }
    }
}

