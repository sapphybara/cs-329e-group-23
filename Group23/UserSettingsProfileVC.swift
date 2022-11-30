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
    @IBOutlet weak var profileImage: UIImageView!
    var user = Auth.auth().currentUser
    override func viewDidLoad() {
        super.viewDidLoad()
        if user == nil {
            // make sure the cached user is not nil here, otherwise logout
            return performSegue(withIdentifier: logoutSegue, sender: self)
        }
//        welcomeMessage.text = "Welcome, \(user?.displayName ?? "friend")!"
        profileImage.layer.borderWidth = 3
        profileImage.layer.borderColor = UIColor(named: "success3")?.cgColor
        // here, get the user's image if exists and set profileImage.image = ...
    }
    
    // make the profile pic exactly circular
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.layer.masksToBounds = false
        profileImage.clipsToBounds = true
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
