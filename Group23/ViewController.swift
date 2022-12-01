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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
    
        // Testing To See If Below Is Junk, Do Not Touch - SL
//        if FirebaseApp.app() == nil {
//            FirebaseApp.configure()
//        }
    }
    
    // disables login screen presentation on second tap of profile tab element
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let tabIdx = tabBarController.viewControllers?.firstIndex(of: viewController)
        return tabIdx != 2 || tabIdx != tabBarController.selectedIndex
    }
}
