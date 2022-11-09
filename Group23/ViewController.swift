//
//  ViewController.swift
//  Group23
//
//  Created by m1 on 11/10/2022.
//

import UIKit
import FirebaseCore
import FirebaseFirestore


class ViewController: UITabBarController, UITabBarControllerDelegate {
    
    @IBOutlet weak var tabBarElement: UITabBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        // allow disabling double tap of profile icon
        delegate = self
        
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
    }

    // disables login screen presentation on second tap of profile tab element
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let tabIdx = tabBarController.viewControllers?.firstIndex(of: viewController)
        return tabIdx != 2 || tabIdx != tabBarController.selectedIndex
    }
    
    // firestore data retrieval and upload, update data in app and in firestore

}
