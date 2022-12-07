//
//  ViewController.swift
//  Group23
//
//  Created by Warren Wiser on 11/10/2022.
//

import UIKit
import FirebaseAuth

let customFontNames = ["Avenir", "Baskerville", "CopperPlate", "Futura-Medium", "Helvetica"]

// global user variable to access user data bucket
var activeUser: User? {
    Auth.auth().currentUser
}

class ViewController: UITabBarController, UITabBarControllerDelegate {
    
    @IBOutlet weak var tabBarElement: UITabBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    }
    
    // disables login screen presentation on second tap of profile tab element
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let tabIdx = tabBarController.viewControllers?.firstIndex(of: viewController)
        return tabIdx != 2 || tabIdx != tabBarController.selectedIndex
    }
}
