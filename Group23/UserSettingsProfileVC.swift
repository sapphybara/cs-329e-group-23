//
//  UserSettingsProfileVC.swift
//  Group23
//
//  Created by Santiago Leyva on 10/17/22.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

// WARREN USE THIS DATA STRUCTURE TO UPLOAD UIIMAGES TO SERVER, profileImageID WILL BE AUTOMATICALLY MADE
// THE ID CAN BE USED TO DISPLAY IMAGE NAME IN THE FOLLOWING FORMAT:
//"Image_\(profileImageDataStructure[0].1).jpeg"
// data structure required for the user profile image data management
private var profileImageDataStructure: [(profileImage: UIImage, profileImageID: Int)] = []

// firebase db storage setup
private let storageRef = Storage.storage(url:"gs://final-project-group-23.appspot.com/").reference()

// THIS NEEDS TESTING
// This function uploads the profile image from device memory to the database for the logged-in user
func serverFileUserImageUpload() {
    // ID Generator
    let imageID = Int.random(in: 0..<100000)
    
    profileImageDataStructure[0].1 = imageID
    
    let imageToUpload: Data = profileImageDataStructure[0].0.jpegData(compressionQuality: 0.1)!
    
    // todo fix to firebase url
    let imageRef = storageRef.child("userProfilePicture/\(activeUser?.email ?? "g@g.com")/Image_\(imageID).jpeg")
    
    print("\nUploading User Profile Image To Database...")
    
    // Upload user profile picture to the appropriate server location for the appropriate user
    _ = imageRef.putData(imageToUpload, metadata: nil)
    
    print("\nUser \(activeUser?.displayName ?? activeUser?.email ?? "NOBODY")'s Profile Image Has Been Uploaded To The Database...")
}

// THIS NEEDS TESTING
// This function retrieves the profile image from the database for the logged-in user
func serverFileUserImageRetrieval() {
    // server bucket reference for user profile data
    
    if let user = activeUser {
        let dbUserFilesRef = storageRef.child("userProfilePicture/\(user.email!)")
        
        print("\nGetting the profile picture for user: \(user.displayName ?? user.email!).")
        dbUserFilesRef.listAll{ (result, error) in
            if let error = error {
                print("\nWARNING: ERROR IN RETREIVING USER PROFILE IMAGE DATA. SEE MESSAGE BELOW - \n\(error.localizedDescription)\n")
            } else {
                
                print("\nRetrieving DB Profile User Image Data...")
                
                // this retreives all profile images from server side and file id's from original file names, although there should always only be one stored in the database. Therefore only get the 0th element in the database
                if result.items.count > 0 {
                    for item in result.items {
                        // get original file id from server-stored file name
                        let strIDNameSearch = String(item.name)
                        let firstIndex = strIDNameSearch.firstIndex(of: "_")
                        let firstIndexOneOver = strIDNameSearch.index(after: firstIndex!)
                        let secondIndex = strIDNameSearch.lastIndex(of: ".")
                        let range = firstIndexOneOver..<secondIndex!
                        let tempFileID = Int(strIDNameSearch[range])!
                        let path = dbUserFilesRef.child("\(strIDNameSearch)")
                        
                        print("-Attempting to retrieve user profile image with ID: \(tempFileID)-")
                        // maxSize is maxSize of INT 64 for swift, just to play it safe
                        path.getData(maxSize: 9223372036854775807) { (data, error) -> Void in
                            print("Getting File...")
                            let bytemanager = Data(data!)
                            profileImageDataStructure[0].0 = UIImage(data: (bytemanager as NSData) as Data)!
                        }
                        
                        profileImageDataStructure[0].1 = tempFileID
                        print("User Profile Image Retreival Path: \(path)")
                        print("Profile Image ID Retrieved = \"\(tempFileID)\"\n")
                        // only get the first element in the database as there should only be one profile image per user
                        break
                    }
                } else {
                    print("\nNo User Profile Stored In Server DB...")
                }
            }
        }
    } else {
        print("user not found, unable to retrieve profile image")
    }
}

// THIS NEEDS TESTING
// This function deletes the profile image from the database for the logged-in user
func serverFileUserImageDeletion() {
    DispatchQueue.global(qos: .default).async() {
        // server bucket reference for user data
        
        if let user = activeUser {
            let dbUserFilesRef = storageRef.child("userProfilePicture/\(user.email!)")
            
            // make server delete request
            if profileImageDataStructure[0].0.imageAsset != nil {
                // server data deletion
                let tempRefServerNode = dbUserFilesRef.child("Image_\(profileImageDataStructure[0].1).jpeg")
                tempRefServerNode.delete { (error) in
                    if let error = error {
                        print("\nWARNING: THERE WAS AN ERROR IN DELETING YOUR USER PROFILE IMAGE DATA. SEE MESSAGE BELOW - \n\(error.localizedDescription)\n")
                    } else {
                        print("~Image_\(profileImageDataStructure[0].1).jpeg Was Successfully Deleted On The Server Side~")
                    }
                }
                
                // sync deleted server user profile image objects with locally stored objects in memory
                DispatchQueue.global(qos: .userInitiated).async() {
                    DispatchQueue.main.async {
                        profileImageDataStructure.remove(at: 0)
                        print("PROFILE IMAGE DATA STRUCTURE CHECK: \(profileImageDataStructure)")
                    }
                }
            }
        } else {
            print("Cannot access an anonymous user's image")
        }
    }
}

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
        
        // WARREN THERE IS AN ISSUE HERE, IF THIS IS COMMENTED OUT, THE VC DOES NOT SEGUE AND PROGRAM BREAKS.
        // THE CODE I WROTE SHOULD WORK, AS THAT IS THE METHOD I USED TO SYNC ALL USER DATA
        // IT MUST BE A BUG WITH THE STORYBOARD/VC SETUP
        //        // database server retrieval of user profile image
        //        activeUser = provideCurrentUser()
        //        serverFileUserImageRetrieval()
        //        print("CHECKING PROFILE IMAGE DATA STRUCTURE: \(profileImageDataStructure)")
        //        profileImage.image = profileImageDataStructure[0].0
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
                            
                            // todo email &/or email? (in message)
                            
                            if textToUpdate.isEmpty {
                                message = "Input for email cannot be empty"
                                wasInputValid = false
                            } else {
                                wasInputValid = emailPred.evaluate(with: textToUpdate)
                            }
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
