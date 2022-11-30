//
//  ViewController.swift
//  Group23
//
//  Created by m1 on 11/10/2022.
//

import UIKit
//import FirebaseCore
//import FirebaseFirestore
import FirebaseAuth

class ViewController: UITabBarController, UITabBarControllerDelegate {
    
    @IBOutlet weak var tabBarElement: UITabBar!
    var currentUser: User?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // allow disabling double tap of profile icon
        delegate = self
    
        // Testing for Junk Below - SL
//        if FirebaseApp.app() == nil {
//            FirebaseApp.configure()
//        }
//
//        // watch for changes in the user
//        Auth.auth().addStateDidChangeListener { auth, user in
//            self.currentUser = user
//        }
    }
    
    // determines which view controller to show - account screen if logged in, else login page
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let index = tabBar.items?.firstIndex(of: item)
        if index == 2 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            var vcToShow: UIViewController
            
            // show either the login screen or the account screen, depending on auth status
            if currentUser == nil {
                vcToShow = storyboard.instantiateViewController(withIdentifier: "loginScreen")
            } else {
                vcToShow = storyboard.instantiateViewController(withIdentifier: "AccountView")
            }
            
            // set the correct page for the profile page
            if let profileNavController = self.viewControllers?[2] as? UINavigationController {
                profileNavController.setViewControllers([vcToShow], animated: true)
            }
        }
    }
}
