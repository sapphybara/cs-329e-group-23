//
//  UserSettingsProfileVC.swift
//  Group23
//
//  Created by Santiago Leyva on 10/17/22.
//

import UIKit
import FirebaseAuth

class UserSettingsProfileVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // Logout Button Action - ERROR HERE. IMPLEMENTATION OF NAVIGATION CONTROLLER MAY BE REQUIRED TO LOGOUT AS EXPECTED
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        do {
            try Auth.auth().signOut() // logs out user is now nil
            self.dismiss(animated: true)
        } catch {
            print("Sign Out Error")
        }
        
    }
    
}
