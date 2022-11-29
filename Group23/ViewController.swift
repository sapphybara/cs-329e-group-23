//
//  ViewController.swift
//  Group23
//
//  Created by m1 on 11/10/2022.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

//internal class PDFFile {
//   var id = 0 // 0 Dummy ID for File
////content = someBinary Object // commented out until this is confirmed
//}
//
//// Global pdfList Object Storage
//var pdfList: [PDFFile] = []
//
//func idMaker(PDFFile: PDFFile, pdfList: pdfList) { // MAX Stick This Code For ID'ing PDF Objects
//    // ID Generator
//    let pdfFileID = Int.random(in: 0..<100000)
//
//    // This will check to see if an ID is already instatiated for any PDF file
//    for pdfFileItem in pdfList {
//        if pdfFileItem.id == pdfFileID {
//            while pdfFileItem.id == pdfFileID {
//                print("\nID \(pdfFileID) Is Already In Use, Generating New PDF File ID\n")
//                let pdfFileID = Int.random(in: 0..<100000)
//                PDFFile.id = pdfFileID
//                continue
//            }
//        } else {
//            PDFFile.id = pdfFileID
//            print("\nNew PDF Files Has An ID of \(pdfFile.id)n")
//        }
//    }
//}

class ViewController: UITabBarController, UITabBarControllerDelegate {
    
    @IBOutlet weak var tabBarElement: UITabBar!
    var currentUser: User?
    override func viewDidLoad() {
        super.viewDidLoad()
        // allow disabling double tap of profile icon
        delegate = self
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
        // watch for changes in the user
        Auth.auth().addStateDidChangeListener { auth, user in
            self.currentUser = user
        }
        
//        let db = Firestore.firestore()
    }
    
    // firestore data retrieval and upload, update data in app and in firestore
    
    
    /// determines which view controller to show - account screen if logged in, else login page
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
