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
        
    }
    
    // Logout Button Action
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        do {
            try Auth.auth().signOut() // logs out, user is now nil
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Sign Out Error")
        }
    }
    
}
