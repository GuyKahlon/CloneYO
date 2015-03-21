//
//  AppDelegate.swift
//  YO
//
//  Created by Guy Kahlon on 1/14/15.
//  Copyright (c) 2015 GuyKahlon. All rights reserved.
//

enum MenuType: Int{
    case Signup = 0 ,Login = 1,  Recover = 2, Main = 10, YO
}

class MenusModel: NSObject {
    
    typealias CellConfiguration = (title: String, inputEnable: Bool)
    
    let main   :[CellConfiguration] = [("SIGNUP",false),("LOGIN",false),("RECOVER PASS",false)]
    
    let signup :Array<CellConfiguration> = [("CHOOSE USERNAME",true),("CHOOSE PASSCODE",true),("ENTER EMAIL",true),("TAP TO SIGNUP",false),("GO BACK",false)]
    let login  :Array<(title: String, inputEnable: Bool)> = [("USERNAME",true),("PASSCODE",true),("TAP TO LOGIN",false),("GO BACK",false)]
    let recover:Array<(title: String, inputEnable: Bool)> = [("USERNAME",true),("TAP TO RECOVER",false),("GO BACK",false)]
    let sendYo :Array<(title: String, inputEnable: Bool)> = [("USERNAME",true),("TAP TO YO",false)]
    
    var dic = [MenuType:[CellConfiguration]]()
    
    override init() {
        dic = [.Main:main,
               .Login: login,
               .Signup: signup,
               .Recover: recover,
               .YO: sendYo]        
        super.init()
    }
    
    func getMenu(menuType: MenuType)->[(title: String, inputEnable: Bool)]{
        
        
        switch menuType{
            case .Main: return main
            case .Login: return login
            case .Signup: return signup
            case .Recover: return recover
            case .YO: return sendYo
        }
    }
}
