//
//  ViewController.swift
//  Group23
//
//  Created by m1 on 11/10/2022.
//

import UIKit

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
