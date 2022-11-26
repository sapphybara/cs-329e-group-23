//
//  ViewController.swift
//  Group23
//
//  Created by m1 on 11/10/2022.
//

import UIKit
import FirebaseCore
import FirebaseFirestore

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
    override func viewDidLoad() {
        super.viewDidLoad()
        // allow disabling double tap of profile icon
        delegate = self
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
        
//        let db = Firestore.firestore()
    }

    // disables login screen presentation on second tap of profile tab element
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let tabIdx = tabBarController.viewControllers?.firstIndex(of: viewController)
        return tabIdx != 2 || tabIdx != tabBarController.selectedIndex
    }
    
    // firestore data retrieval and upload, update data in app and in firestore

}
