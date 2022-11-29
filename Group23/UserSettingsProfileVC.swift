//
//  UserSettingsProfileVC.swift
//  Group23
//
//  Created by Santiago Leyva on 10/17/22.
//

import UIKit
import FirebaseAuth

class UserSettingsProfileVC: UIViewController {
    
    let logoutSegue = "logoutSegue"
    
    @IBOutlet weak var welcomeMessage: UILabel!
    var user = Auth.auth().currentUser
    override func viewDidLoad() {
        super.viewDidLoad()
        if user == nil {
            // make sure the cached user is not nil here, otherwise logout
            return performSegue(withIdentifier: logoutSegue, sender: self)
        }
        welcomeMessage.text = "Welcome, \(user?.displayName ?? "friend")!"
    }
    
    // Logout Button Action
    @IBAction func logoutButtonPressed(_ sender: Any) {
        
        do {
            try Auth.auth().signOut() // logs out, user is now nil
        } catch {
            print("Sign Out Error")
        }
    }
    
}
