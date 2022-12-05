//
//  SettingsVC.swift
//  Group23
//
//  Created by Warren Wiser on 02/12/2022.
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
        
    @IBAction func handleDarkModeSwitch(_ sender: Any) {
        currentMode = darkModeSwitch.isOn ? .dark : .light
        view.window?.windowScene?.keyWindow?.overrideUserInterfaceStyle = currentMode
    }
}
