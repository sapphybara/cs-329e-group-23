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
    var containerSegue = "tableSegue"
    
    @IBOutlet weak var profileOrName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var actionView: UIView!
    var user = Auth.auth().currentUser
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentUser = user {
            profileImage.layer.borderWidth = 3
            profileImage.layer.borderColor = UIColor(named: "success3")?.cgColor
            if let name = currentUser.displayName {
                profileOrName.text = "Welcome, \(name)";
            }
        } else {
            // make sure the cached user is not nil here, otherwise logout
            return performSegue(withIdentifier: logoutSegue, sender: self)
        }
        
    }
    
    // make the profile pic exactly circular
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.layer.masksToBounds = false
        profileImage.clipsToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == containerSegue, let table = segue.destination as? ProfileTable {
            table.view.translatesAutoresizingMaskIntoConstraints = false
        }
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
