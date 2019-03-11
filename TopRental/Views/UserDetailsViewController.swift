//
//  UserDetailsViewController.swift
//  TopRental
//
//  Created by Frank Mao on 2019-01-13.
//  Copyright © 2019 mazoic. All rights reserved.
//

import UIKit
import Parse
import JVFloatLabeledTextField
import YPImagePicker
import SVProgressHUD
class UserDetailsViewController: UITableViewController {

    var user : PFUser?
    @IBOutlet weak var avatarImageView: PFImageView!
    
    @IBOutlet weak var usernameLabel: JVFloatLabeledTextField!
    
    @IBOutlet weak var emailLabel: JVFloatLabeledTextField!
    
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    
    @IBOutlet weak var roleSwitcher: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.tableFooterView = UIView(frame: .zero)
        refreshUI()
    }

    func refreshUI()  {
        
        guard let user = user else {
            return
        }
        

        
        self.usernameLabel.text = user.username
        self.emailLabel.text = user.email
        
        self.roleSwitcher.selectedSegmentIndex = user.role.rawValue
        self.avatarImageView.file = user.avatar
        self.avatarImageView.loadInBackground()
        
        // ACL reason, user can not directly see other user's private info, e.g. email.
        // Use cloud code instead
        if user.objectId != PFUser.current()?.objectId {
            PFCloud.callFunction(inBackground: "fetchUser",
                                 withParameters: ["userId": user.objectId as Any])
            { (result, error) in
                if let result = result as? Dictionary<String, Any>,
                    let user = result["user"] as? PFUser,
                    let email = user.email {
                    self.emailLabel.text = email
                }
            }
        }
    }
    
    @IBAction func onPromptSelectionNewAvatar(_ sender: Any) {

        var config = YPImagePickerConfiguration()
        config.startOnScreen = YPPickerScreen.photo
        config.screens = [.library, .photo]
        config.showsFilters = false
        
        let picker = YPImagePicker(configuration: config)
        
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                
                self.saveNewAvatarImage(image: photo.image)
                
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)

    }
    
    func saveNewAvatarImage(image: UIImage) {
        guard let data = image.pngData() else {
            return
        }
        // TODO: resize avatar to smaller size.
        if self.user?.objectId == PFUser.current()?.objectId {
            
            self.user?.avatar = PFFileObject(data: data)
            SVProgressHUD.show()
            self.user?.saveInBackground(block: { (success, error) in
                SVProgressHUD.dismiss()
                if success {
                    self.avatarImageView.image = image

                     NotificationCenter.default.post(name: NSNotification.Name(AppNotification.UserInfoChanged.rawValue), object: nil)
                }
            })
            
        }else{
            // save a new userAvatar record, let cloud code to update avatar data on user table, by pass ACL
            let userAvatar = PFObject(className: "UserAvatar")
            userAvatar["user"] = self.user
            userAvatar["avatar"] = PFFileObject(data: data)
            
            SVProgressHUD.show()
            userAvatar.saveInBackground { (success, error) in
                SVProgressHUD.dismiss()
                if success {
                    self.avatarImageView.image = image

                    NotificationCenter.default.post(name: NSNotification.Name(AppNotification.UserInfoChanged.rawValue), object: nil)
                }
            }
        }
    }
    
    @IBAction func onSave(_ sender: Any) {
        
        
        
        var errors : [String] = []
        
        if user?.username?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            errors.append("username is required")
        }
        
        if user?.email?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            errors.append("email is required")
        }
        
        if errors.count == 0 {
            errorMessageLabel.text = ""
            
            self.user?.username = self.usernameLabel.text
            self.user?.email = self.emailLabel.text
            
            if self.user?.objectId == nil {
                // new user
                
                self.user?.password = self.emailLabel.text // default email as original pwd
                
                PFCloud.callFunction(inBackground: "createUser"
                , withParameters: [
                    "username": self.user?.username as Any,
                    "email": self.user?.email as Any,
                    "password": self.user?.password as Any,
                    "role": self.roleSwitcher.selectedSegmentIndex
                                   ]) { (result, error) in
                    
                    if let error = error {
                        self.errorMessageLabel.text = error.localizedDescription
                    }
                    
                    if let _ = result {
                        
                        self.navigationController?.popViewController(animated: true)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(AppNotification.UserInfoChanged.rawValue), object: nil)
                        
                    }
                }
            }else{
                
                if self.user?.objectId == PFUser.current()?.objectId {
                    self.user?.saveInBackground(block: { (success, error) in
                        if let error = error {
                            self.errorMessageLabel.text = error.localizedDescription
                        }
                        
                        if success {
                            self.navigationController?.popViewController(animated: true)
                            
                            NotificationCenter.default.post(name: NSNotification.Name(AppNotification.UserInfoChanged.rawValue), object: nil)
                        }
                    })
                   
                }else{
                    PFCloud.callFunction(inBackground: "modifyUser",
                                         withParameters:
                        [
                            "userId": self.user?.objectId as Any,
                            "username": self.usernameLabel.text as Any,
                            "email": self.emailLabel.text as Any,
                            "role": self.roleSwitcher.selectedSegmentIndex as Any
                        ])
                    { (result, error) in
                        if let _ = result {
                            self.navigationController?.popViewController(animated: true)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(AppNotification.UserInfoChanged.rawValue), object: nil)
                        }
                    }
                }
                
            }
        }else{
            errorMessageLabel.text = errors.joined(separator: "\n")
        }

    }
    
    func promptPasswordInit() {
        // ask for set original password
        let alert = UIAlertController(title: "Set Password", message: "Please input original password", preferredStyle: UIAlertController.Style.alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            // Get TextFields text
            let passwordTxt = alert.textFields![0]
            let passwordConfirmTxt = alert.textFields![1]
            
            if passwordTxt.text == passwordConfirmTxt.text {
                self.user?.password = self.emailLabel.text // default email as original pwd
                self.user?.username = self.usernameLabel.text
                self.user?.email = self.emailLabel.text
                
                self.user?.signUpInBackground(block: { (success, error) in
                    if let error = error {
                        self.errorMessageLabel.text = error.localizedDescription
                    }
                    
                    if success {
                        
                        self.navigationController?.popViewController(animated: true)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(AppNotification.UserInfoChanged.rawValue), object: nil)
                        
                    }
                })
            }
            
            
        })
        
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.placeholder = "Type your password"
            textField.isSecureTextEntry = true
            
            
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification,
                                                   object: textField, queue: OperationQueue.main, using:
                {_ in
                    
                    let passwordTxt = alert.textFields![0]
                    let passwordConfirmTxt = alert.textFields![1]
                    okAction.isEnabled = passwordTxt.text == passwordConfirmTxt.text
                    
            })
        }
        
        alert.addTextField { (textField: UITextField) in
            textField.keyboardAppearance = .dark
            textField.keyboardType = .default
            textField.placeholder = "Confirm password"
            textField.isSecureTextEntry = true
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification,
                                                   object: textField, queue: OperationQueue.main, using:
                {_ in
                    
                    let passwordTxt = alert.textFields![0]
                    let passwordConfirmTxt = alert.textFields![1]
                    okAction.isEnabled = passwordTxt.text == passwordConfirmTxt.text
                    
            })
            
        }
        
        
        alert.addAction(okAction)
        
        okAction.isEnabled = false
        
        present(alert, animated: true, completion: nil)
    }
    
    
    
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
