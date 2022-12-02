//
//  SettingsVC.swift
//  Group23
//
//  Created by m1 on 02/12/2022.
//

import UIKit

class SettingsVC: UIViewController {

    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var hapticsSwitch: UISwitch!
    @IBOutlet weak var scanColorPicker: UIPickerView!
    
    var currentMode: UIUserInterfaceStyle!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentMode = traitCollection.userInterfaceStyle
        darkModeSwitch.isOn = currentMode != .light
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func handleDarkModeSwitch(_ sender: Any) {
        currentMode = darkModeSwitch.isOn ? .dark : .light
        view.window?.windowScene?.keyWindow?.overrideUserInterfaceStyle = currentMode
    }
}
