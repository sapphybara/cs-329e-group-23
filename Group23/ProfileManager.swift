//
//  ProfileManager.swift
//  Group23
//
//  Created by m1 on 20/10/2022.
//

import UIKit
import FirebaseAuth

class ProfileManager: UINavigationController {
    
    @IBOutlet weak var scanNavBar: UINavigationBar!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        if (Auth.auth().currentUser != nil) { // check if user is logged in
            let loginVC = storyBoard.instantiateViewController(withIdentifier: "LoginView") as! ProfileVC
            self.pushViewController(loginVC, animated: true)
        }  else {
            let accountVC = storyBoard.instantiateViewController(withIdentifier: "AccountView") as! UserSettingsProfileVC
            self.pushViewController(accountVC, animated: true)
        }
    }
    
}
