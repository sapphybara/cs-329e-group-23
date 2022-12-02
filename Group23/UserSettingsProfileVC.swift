//
//  UserSettingsProfileVC.swift
//  Group23
//
//  Created by Santiago Leyva on 10/17/22.
//

import UIKit
import FirebaseAuth

class UserSettingsProfileVC: UIViewController, UITextFieldDelegate {
    
    let logoutSegue = "logoutSegue"
    let containerSegue = "tableSegue"
    let preferredTextFieldHeight = 35
    let pencilImg = UIImage(systemName: "pencil")
    let saveImg = UIImage(systemName: "checkmark")
    let attributes = ["Name", "Phone Number", "Email"]
    let mediumTextColor = UIColor(named: "text-medium-emphasis")
    let disabledTextColor = UIColor(named: "text-disabled")
    
    // regex from https://regexlib.com/
    let emailPred = NSPredicate(format: "SELF MATCHES %@", "^\\w+([-+.']\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$")
    let phonePred = NSPredicate(format: "SELF MATCHES %@", "((\\(\\d{3}\\)?)|(\\d{3}))([\\s-./]?)(\\d{3})([\\s-./]?)(\\d{4})")
    
    var user = Auth.auth().currentUser
    var isUserEditingProfile = false
    
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var editOverlay: UIImageView!
    @IBOutlet weak var cancelEdit: UIButton!
    
    @IBOutlet weak var valuesStack: UIStackView!
    @IBOutlet weak var inputStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let currentUser = user {
            profileImage.layer.borderWidth = 3
            profileImage.layer.borderColor = UIColor(named: "success3")?.cgColor
            
            setValueAndColor(value: currentUser.displayName, label: displayName)
            setValueAndColor(value: currentUser.phoneNumber, label: phone)
            setValueAndColor(value: currentUser.email, label: email)
            // rotate plus icon to be an x
            cancelEdit.transform = CGAffineTransform(rotationAngle: 0.7853981634)
            cancelEdit.isHidden = true
        } else {
            // make sure the cached user is not nil here, otherwise logout
            return performSegue(withIdentifier: logoutSegue, sender: self)
        }
		
		for fieldView in inputStack.arrangedSubviews {
			if let txtField = fieldView as? UITextField {
				txtField.delegate = self
			}
		}
    }
    
    /// sets the value of the user's metadata, as well as text color depending on status
    func setValueAndColor(value: String?, label: UILabel) {
        if let val = value {
            label.text = val
            label.textColor = mediumTextColor
        } else {
            label.text = "undefined"
            label.textColor = disabledTextColor
        }
    }
    
    // make the profile pic exactly circular after it's frame is fully defined
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.layer.masksToBounds = false
        profileImage.clipsToBounds = true
    }
    
    // Logout Button Action
    @IBAction func logoutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut() // logs out, user is now nil
        } catch {
            print("Sign Out Error")
        }
    }
    
    func switchView(btn: UIButton) {
        isUserEditingProfile = !isUserEditingProfile
        btn.setImage(isUserEditingProfile ? saveImg : pencilImg, for: .normal)
        inputStack.isHidden = !isUserEditingProfile
        valuesStack.isHidden = isUserEditingProfile
        editOverlay.isHidden = !isUserEditingProfile
        profileImage.alpha = isUserEditingProfile ? 0.75 : 1
    }
    
    @IBAction func handleProfileEdit(_ sender: UIButton) {
        switchView(btn: sender)
        
        if sender.currentImage == pencilImg {
            var valuesToSave: [String] = []
            var wasInputValid = true
            for (i, el) in inputStack.arrangedSubviews.enumerated() {
                if let txtField = el as? UITextField {
                    if !isUserEditingProfile, let textToUpdate = txtField.text {
                        var message = "Invalid \(attributes[i])."
                        
                        if i == 1 {
                            wasInputValid = phonePred.evaluate(with: textToUpdate)
                        } else if i == 2 {
                            wasInputValid = emailPred.evaluate(with: textToUpdate)
                        }
                        
                        if textToUpdate.isEmpty {
                            message = "Input for \(attributes[i]) cannot be empty"
                            wasInputValid = false
                        }
                        
                        if let currentValue = valuesStack.arrangedSubviews[i] as? UILabel {
                            if textToUpdate == currentValue.text {
                                message = "You cannot save the same information as before, check the \(attributes[i]) field."
                                wasInputValid = false
                            }
                        }
                        
                        if !wasInputValid {
                            let alertController = UIAlertController(title: "ERROR: Save cancelled", message: message, preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "Ok", style: .destructive))
                            switchView(btn: sender)
                            present(alertController, animated: true)
                            break
                        } else {
                            valuesToSave.append(textToUpdate)
                        }
                    }
                }
            }
            
            // sets the fields to the valid input, updates user in firebase
            if !valuesToSave.isEmpty && wasInputValid {
                valuesStack.arrangedSubviews.enumerated().forEach { (i, el) in
                    if let label = el as? UILabel {
                        label.textColor = mediumTextColor
                        label.text = valuesToSave[i]
                    }
                }
//                let currentUser = Auth.auth().currentUser
//                let userUpdateRequest = currentUser?.createProfileChangeRequest()
//                valuesToSave.enumerated().forEach { i, val in
//                    switch i {
//                    case 0:
//                        userUpdateRequest?.displayName = valuesToSave[0]
//                    case 2:
//                        currentUser?.updateEmail(to: valuesToSave[1]) { err in
//                            if let error = err as NSError? {
//                                print("Couldn't save email: \(error.localizedDescription)")
//                            }
//                        }
//                    case 1:
//                        let phoneCreds = new FirebaseAuth.PhoneAuthCredential()
//                    default:
//                        break
//                    }
//                }
            }
        }
    }
    
    @IBAction func handleEditCancel(_ sender: Any) {
//        switchView(btn: nil)
    }
	
	/// Called when 'return' key pressed
   func textFieldShouldReturn(_ textField:UITextField) -> Bool {
	   textField.resignFirstResponder()
	   return true
   }
   
   /// Called when the user clicks on the view outside of the UITextField
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
	   self.view.endEditing(true)
   }
}
