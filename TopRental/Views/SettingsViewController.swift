//
//  SecondViewController.swift
//  TopRental
//
//  Created by Frank Mao on 2019-01-12.
//  Copyright © 2019 mazoic. All rights reserved.
//

import UIKit
import Parse
import SVProgressHUD

class SettingsViewController: UIViewController {

    @IBOutlet weak var logInLogOutButton: UIButton!
    @IBOutlet weak var usersButton: UIButton!
    @IBOutlet weak var rentalsButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(AppNotification.UserLoggedIn.rawValue), object: nil, queue: nil) { (notif) in
            self.refreshUI()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(AppNotification.UserLoggedOut.rawValue), object: nil, queue: nil) { (notif) in
            self.refreshUI()
        }
        
        self.refreshUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func refreshUI() {
        
        if let currentUser = PFUser.current() {
            logInLogOutButton.setTitle("Log out from \(currentUser.username ?? "")", for: .normal)
            
            self.usersButton.isHidden = !currentUser.isAdmin
            self.rentalsButton.isHidden = !currentUser.isAdmin && !currentUser.isRealtor
     
            
        }else{
            logInLogOutButton.setTitle("Log In", for: .normal)
            usersButton.isHidden = true
            rentalsButton.isHidden = true
        }
    }
    
    func showLogin() {
        let logInViewController = TRLoginViewController()
        
 
        logInViewController.delegate = self
        logInViewController.signUpController?.delegate = self
        self.present(logInViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func onLoginLogout(_ sender: Any) {
        
        if PFUser.current() == nil {
            self.showLogin()
        }else{
            // TODO: confirm logging out
            SVProgressHUD.show()
            PFUser.logOutInBackground(block: { (e) in
                SVProgressHUD.dismiss()
                if let e = e {
                    print("log out error, \(e)")
                }else{
                     NotificationCenter.default.post(name: NSNotification.Name(AppNotification.UserLoggedOut.rawValue), object: nil)
                }
            })
    
            
           
        }
    }
    
  
}

extension SettingsViewController : PFSignUpViewControllerDelegate {
    func signUpViewController(_ signUpController: PFSignUpViewController, didSignUp user: PFUser) {
        NotificationCenter.default.post(name: NSNotification.Name(AppNotification.UserLoggedIn.rawValue), object: nil)
        
        self.dismiss(animated: true) {
            
        }
    }
}

    
extension SettingsViewController : PFLogInViewControllerDelegate {
    
    func log(_ logInController: PFLogInViewController, didLogIn user: PFUser) {
        
        NotificationCenter.default.post(name: NSNotification.Name(AppNotification.UserLoggedIn.rawValue), object: nil)
        
        self.dismiss(animated: true) {
            
        }
    }
    

    
}
