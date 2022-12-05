//
//  SettingsVC.swift
//  Group23
//
//  Created by Warren Wiser on 02/12/2022.
//

import UIKit

var allowHaptics:Bool = false

class SettingsVC: UIViewController {

    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var hapticsSwitch: UISwitch!
    @IBOutlet weak var scanColorPicker: UIPickerView!
    
    var currentMode: UIUserInterfaceStyle!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentMode = traitCollection.userInterfaceStyle
        darkModeSwitch.isOn = currentMode != .light
        hapticsSwitch.isOn = allowHaptics
    }
        
    @IBAction func handleDarkModeSwitch(_ sender: Any) {
        currentMode = darkModeSwitch.isOn ? .dark : .light
        view.window?.windowScene?.keyWindow?.overrideUserInterfaceStyle = currentMode
    }
    
    @IBAction func handleHapticsSwitch(_ sender: Any) {
        if (hapticsSwitch.isOn == true){
            allowHaptics = true
            print("Haptics now enabled")
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }else {
            allowHaptics = false
            print("Haptics now disabled")
        }
        
        
        
    }
    
}
