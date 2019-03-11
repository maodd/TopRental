//
//  TRLoginViewController.swift
//  TopRental
//
//  Created by Frank Mao on 2019-01-12.
//  Copyright © 2019 mazoic. All rights reserved.
//

import UIKit
import Parse

class TRLoginViewController: PFLogInViewController {

    
    
    override func viewWillAppear(_ animated: Bool) {
        
      
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.logInView?.logo = UIImageView(image: UIImage(named: "logo"))
        self.signUpController?.signUpView?.logo = UIImageView(image: UIImage(named: "logo"))
      
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
