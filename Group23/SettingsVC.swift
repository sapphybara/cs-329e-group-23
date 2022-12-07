//
//  SettingsVC.swift
//  Group23
//
//  Created by Warren Wiser on 02/12/2022.
//

import UIKit

var allowHaptics:Bool = false

class SettingsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var hapticsSwitch: UISwitch!
    @IBOutlet weak var fontPicker: UIPickerView!
    
    var currentMode: UIUserInterfaceStyle!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentMode = traitCollection.userInterfaceStyle
        darkModeSwitch.isOn = currentMode != .light
        hapticsSwitch.isOn = allowHaptics
        
        fontPicker.delegate = self
        fontPicker.dataSource = self
        
        // set the correct row in the picker for the selected font
        fontPicker.selectRow(customFontNames.firstIndex(of: UILabel.appearance().substituteFontName)!, inComponent: 0, animated: false)
    }
    
    @IBAction func handleDarkModeSwitch(_ sender: Any) {
        currentMode = darkModeSwitch.isOn ? .dark : .light
        view.window?.windowScene?.keyWindow?.overrideUserInterfaceStyle = currentMode
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func handleHapticsSwitch(_ sender: Any) {
        if (hapticsSwitch.isOn == true){
            allowHaptics = true
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        } else {
            allowHaptics = false
        }
    }
    
    // MARK: - font picker setup
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return customFontNames.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return customFontNames[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // from same post as in FontExtenders.swift
        UILabel.appearance().substituteFontName = customFontNames[row]
        UITextView.appearance().substituteFontName = customFontNames[row]
        UITextField.appearance().substituteFontName = customFontNames[row]
    }
}
