//
//  HomeVC.swift
//  Group23
//
//  Created by m1 on 06/10/2022.
//

import UIKit

class HomeVC: UIViewController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // todo this should prevent the profile page from popping to the login page on second click
        let tabIdx = tabBarController.viewControllers?.firstIndex(of: viewController)
        return tabIdx != 2 || tabIdx != tabBarController.selectedIndex
    }
}
