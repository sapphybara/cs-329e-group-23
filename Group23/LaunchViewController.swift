//
//  LaunchViewController.swift
//  Group23
//
//  Created by Maxwell Kretschmer on 12/5/22.
//

import UIKit

class LaunchViewController: UIViewController {
    
    @IBOutlet weak var progressView: UIProgressView!
    
    let segueID = "launchDoneSegue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        CATransaction.setCompletionBlock({ 
            self.performSegue(withIdentifier: self.segueID, sender: nil)
        })
        
        UIView.animate(withDuration: 4.0) {
            self.progressView.setProgress(1.0, animated: true)
        }
    }
    
}
