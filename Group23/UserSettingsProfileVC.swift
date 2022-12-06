//
//  UserSettingsProfileVC.swift
//  Group23
//
//  Created by Santiago Leyva on 10/17/22.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

// data structure required for the user profile image data management
private var profileImageDataStructure: [(profileImage: UIImage, profileImageID: Int)] = []

// firebase db storage setup
private let storageRef = Storage.storage(url:"gs://final-project-group-23.appspot.com/").reference()

// This function uploads the profile image from device memory to the database for the logged-in user
func serverFileUserImageUpload(profilePic: UIImage) {
    if let user = activeUser {
        // ID Generator
        let imageID = Int.random(in: 0..<100000)
        profileImageDataStructure = [(profilePic, imageID)]
        
        let imageToUpload: Data = profilePic.jpegData(compressionQuality: 0.1)!
        
        let imageRef = storageRef.child("userProfilePicture/\(user.email!)/Image_\(imageID).jpeg")
        
        // Upload user profile picture to the appropriate server location for the appropriate user
        _ = imageRef.putData(imageToUpload, metadata: nil)
    }
}

// This function retrieves the profile image from the database for the logged-in user
func serverFileUserImageRetrieval(completion: @escaping () -> Void) {
    // server bucket reference for user profile data
    
    if let user = activeUser {
        // new task for async multithreading
        Task {
            let dbUserFilesRef = storageRef.child("userProfilePicture/\(user.email!)")
            do {
                let userFiles = try await dbUserFilesRef.list(maxResults: 1)
                if let item = userFiles.items.first {
                    // get original file id from server-stored file name
                    let strIDNameSearch = String(item.name)
                    let idIdx = strIDNameSearch.lastIndex(of: "_")
                    let firstIndexOneOver = strIDNameSearch.index(after: idIdx!)
                    let extensionIdx = strIDNameSearch.lastIndex(of: ".")
                    let range = firstIndexOneOver..<extensionIdx!
                    let tempFileID = Int(strIDNameSearch[range])!
                    let path = dbUserFilesRef.child("\(strIDNameSearch)")
                    
                    // maxSize is maxSize of INT 64 for swift, just to play it safe
                    path.getData(maxSize: 9223372036854775807) { (data, error) in
                        let bytemanager = Data(data!)
                        let tmpImg = UIImage(data: (bytemanager as NSData) as Data)!
                        profileImageDataStructure = [(tmpImg, tempFileID)]
                        // update image on main (UI) thread
                        DispatchQueue.main.async {
                            completion()
                        }
                    }
                } else {
                    print("no profile picture for \(user.email!)")
                }
            } catch {
                print("Error retrieving profile pic: \(error.localizedDescription)")
            }
        }
    } else {
        print("user not found, unable to retrieve profile image")
    }
}

// This function deletes all profile images to ensure there will be no random file to replace their picture
func serverFileUserImageDeletion(profilePickReference: UIImageView) {
    Task {
        if let user = activeUser {
            // server bucket reference for user data
            let dbUserFilesRef = storageRef.child("userProfilePicture/\(user.email!)")
            
            // make server delete request
            if profileImageDataStructure[0].0.imageAsset != nil {
                do {
                    let allUserPics = try await dbUserFilesRef.listAll()
                    allUserPics.items.forEach { item in
                        item.delete() { error in
                            if let error = error {
                                print("cannot delete file:", error.localizedDescription)
                            }
                        }
                    }
                    // UI update on main thread
                    DispatchQueue.main.async {
                        profilePickReference.image = UIImage(named: "default profile image")!
                    }
                } catch {
                    print("\nWARNING: THERE WAS AN ERROR IN DELETING YOUR USER PROFILE IMAGE DATA. SEE MESSAGE BELOW - \n\(error.localizedDescription)\n")
                }
                
                // sync deleted server user profile image objects with locally stored objects in memory
                profileImageDataStructure = []
            }
        } else {
            print("Cannot access an anonymous user's image")
        }
    }
}

class UserSettingsProfileVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let logoutSegue = "logoutSegue"
    let containerSegue = "tableSegue"
    let pencilImg = UIImage(systemName: "pencil")
    let saveImg = UIImage(systemName: "checkmark")
    let attributes = ["Name", "Email", "Password"]
    let mediumTextColor = UIColor(named: "text-medium-emphasis")
    let disabledTextColor = UIColor(named: "text-disabled")
    
    // regex from https://regexlib.com/
    let emailPred = NSPredicate(format: "SELF MATCHES %@", "^\\w+([-+.']\\w+)*@\\w+([-.]\\w+)*\\.\\w+([-.]\\w+)*$")
    var isUserEditingProfile = false
    var didEditImage = false
    var doesNeedAuth = false
    
    @IBOutlet weak var displayName: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var password: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileEditOverlay: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var cancelEditButton: UIButton!
    
    @IBOutlet weak var valuesStack: UIStackView!
    @IBOutlet weak var inputStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let currentUser = activeUser else {
            return performSegue(withIdentifier: logoutSegue, sender: self)
        }
        
        // asynchonously sets user image once retrieved
        serverFileUserImageRetrieval() {
            if !profileImageDataStructure.isEmpty {
                self.profileImage.image = profileImageDataStructure[0].0
            }
        }
        
        // set values to the current user's attributes, some may be undefined
        let inputs = inputStack.arrangedSubviews as! [UITextField]
        setValueAndColor(value: currentUser.displayName, label: displayName, txtInput: inputs[0])
        setValueAndColor(value: currentUser.email, label: email, txtInput: inputs[1])
        setValueAndColor(value: "******", label: password, txtInput: inputs[2], isPasswordField: true)
        // rotate plus icon to be an x (45 deg in rad)
        cancelEditButton.transform = CGAffineTransform(rotationAngle: 0.7853981634)
        cancelEditButton.isHidden = true
        
        for fieldView in inputStack.arrangedSubviews {
            if let txtField = fieldView as? UITextField {
                txtField.delegate = self
            }
        }
        
        // handle click of user image edit UIImage
        let profilePictureTap = UITapGestureRecognizer(target: self, action: #selector(editUserImage))
        profileEditOverlay.addGestureRecognizer(profilePictureTap)
        profileEditOverlay.isUserInteractionEnabled = true
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(recognizeSwipeGesture(recognizer:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
    }
    @IBAction func recognizeSwipeGesture(recognizer: UISwipeGestureRecognizer)
    {
        if recognizer.direction == .right{
            print("swiped right")
            self.tabBarController?.selectedIndex -= 1
        }
    }
    
    /// sets the value of the user's metadata, as well as text color depending on status
    func setValueAndColor(value: String?, label: UILabel, txtInput: UITextField, isPasswordField: Bool = false) {
        if let val = value {
            label.text = val
            label.textColor = mediumTextColor
            if !isPasswordField {
                txtInput.text = val
            }
        } else {
            label.text = "undefined"
            label.textColor = disabledTextColor
        }
    }
    
    // make the profile pic exactly circular after it's frame is fully defined
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        profileImage.layer.borderWidth = 3
        profileImage.layer.borderColor = UIColor(named: "success3")?.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height / 2
        profileImage.layer.masksToBounds = false
        profileImage.clipsToBounds = true
    }
    
    // Logout Button Action
    @IBAction func logoutButtonPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut() // logs out, user is now nil
            // remove all pdfs from local memory so they cannot see someone else's code
            listPDFThumbnails = []
            pdfStoredObjects = []
        } catch {
            print("Sign Out Error")
        }
    }
    
    // changes to/from edit mode
    func switchView() {
        isUserEditingProfile = !isUserEditingProfile
        editButton.setImage(isUserEditingProfile ? saveImg : pencilImg, for: .normal)
        cancelEditButton.isHidden = !isUserEditingProfile
        inputStack.isHidden = !isUserEditingProfile
        valuesStack.isHidden = isUserEditingProfile
        profileEditOverlay.isHidden = !isUserEditingProfile
        profileImage.alpha = isUserEditingProfile ? 0.75 : 1
    }
    
    @IBAction func handleProfileEdit(_ sender: UIButton) {
        switchView()
        
        if sender.currentImage == pencilImg {
            var valuesToSave: [String] = []
            var wasInputValid = true
            for (i, el) in inputStack.arrangedSubviews.enumerated() {
                if let txtField = el as? UITextField {
                    if !isUserEditingProfile, let textToUpdate = txtField.text {
                        // the only validation we need is for the email format
                        let message = "Check the format of your email"
                        
                        if i == 1 {
                            wasInputValid = emailPred.evaluate(with: textToUpdate)
                        }
                        
                        if !wasInputValid {
                            let alertController = UIAlertController(title: "ERROR: Cannot save user info", message: message, preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "Ok", style: .default))
                            switchView()
                            present(alertController, animated: true)
                            break
                        } else {
                            valuesToSave.append(textToUpdate)
                        }
                    }
                }
            }
            
            // sets the fields to the valid input, updates user in firebase
            if wasInputValid {
                if let currentUser = activeUser {
                    var shouldPresentController = false
                    let controller = UIAlertController(title: "User update error", message: "Coudn't update user settings", preferredStyle: .alert)
                    valuesToSave.enumerated().forEach { i, val in
                        switch i {
                        case 0:
                            let userUpdateRequest = currentUser.createProfileChangeRequest()
                            userUpdateRequest.displayName = valuesToSave[0]
                            userUpdateRequest.commitChanges() {error in
                                if let error = error {
                                    shouldPresentController = true
                                    controller.message = error.localizedDescription
                                }
                            }
                        case 1:
                            currentUser.updateEmail(to: valuesToSave[1]) { error in
                                shouldPresentController = self.reauthenticateUser(controller: controller, currentUser: currentUser, authType: self.attributes[1], error: error)
                            }
                        case 2:
                            currentUser.updatePassword(to: valuesToSave[2]) { error in
                                shouldPresentController = self.reauthenticateUser(controller: controller, currentUser: currentUser, authType: self.attributes[2], error: error)
                            }
                        default:
                            break
                        }
                    }
                    
                    if shouldPresentController {
                        controller.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                        present(controller, animated: true)
                    } else {
                        self.valuesStack.arrangedSubviews.enumerated().forEach { (i, el) in
                            if i != 2, let label = el as? UILabel {
                                label.textColor = self.mediumTextColor
                                label.text = valuesToSave[i]
                            }
                        }
                        if let pwInput = self.inputStack.arrangedSubviews.last as? UITextField {
                            pwInput.text = ""
                        } else {
                            print("failed resetting pw field")
                        }
                    }
                }
            }
        }
    }
    
    /// checks if the user has logged in recently enough, otherwise refresh their creds
    /// - Parameters:
    ///     - controller: the alert controller who message to change
    ///     - currentUser: the non optional user unpacked before calling this
    ///     - authType: one of attributes (name, email, pw)
    ///     - error: error to handle if the user is not recent
    /// - Returns: whether the user needs to reauth or not
    func reauthenticateUser(controller: UIAlertController, currentUser: User, authType: String, error: Error?) -> Bool{
        var shouldPresentController = false
        if let error = error {
            if let code = AuthErrorCode(rawValue: error._code) {
                switch code {
                case .emailAlreadyInUse:
                    controller.message = "An account already exists with that email, please choose a new one"
                    shouldPresentController = true
                case .requiresRecentLogin:
                    let passwordController = UIAlertController(title: "Please re-enter your password to update your \(authType)", message: "Your credentials have timed out", preferredStyle: .alert)
                    passwordController.addTextField() { field in
                        field.delegate = self
                        field.placeholder = "******"
                        field.isSecureTextEntry = true
                        shouldPresentController = true
                    }
                    passwordController.addAction(UIAlertAction(title: "Submit", style: .default) {_ in
                        if let password = passwordController.textFields?[0].text! {
                            let credential = EmailAuthProvider.credential(withEmail: currentUser.email!, password: password)
                            currentUser.reauthenticate(with: credential) { _, error in
                                if error != nil {
                                    self.switchView()
                                    self.warningLabel.text = "Password verification failed"
                                }
                            }
                        } else {
                            controller.message = "Invalid password input"
                            shouldPresentController = true
                        }
                    })
                    passwordController.addAction(UIAlertAction(title: "Cancel", style: .cancel) {_ in
                        self.switchView()
                    })
                    
                    // gets the user's password to re auth
                    present(passwordController, animated: true)
                default:
                    break
                }
            }
        }
        return shouldPresentController
    }
    
    // cancel any staged edits from text fields
    @IBAction func handleEditCancel(_ sender: Any) {
        switchView()
        warningLabel.text = ""
    }
    
    // create & present an imagePicker of given type
    // from Warren's hw10
    func showPicker(type: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = type
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = .fullScreen
        present(imagePicker, animated: true)
    }
    
    // creates a picker from the user's saved photos
    @IBAction func handleAddFromLibrary(_ sender: Any) {
        showPicker(type: .savedPhotosAlbum)
    }
    
    // picker for camera
    @IBAction func handleAddNewImage(_ sender: Any) {
        showPicker(type: .camera)
    }
    
    // remove the image picker without doing anything
    func selectNoImage(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // catch cancel event
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        selectNoImage(picker)
    }
    
    // when a valid image is selected, dismiss the picker and add it to the total number of images used
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // ensure valid image
        let optionalEditedImg = (info[.editedImage] != nil) ? info[.editedImage] as? UIImage : info[.originalImage] as? UIImage
        guard let image = optionalEditedImg else {
            return selectNoImage(picker)
        }
        picker.dismiss(animated: true) {
            serverFileUserImageUpload(profilePic: image)
            self.profileImage.image = image
            self.switchView()
        }
    }
    
    // updates the user's profile image
    @IBAction func editUserImage() {
        let controller = UIAlertController(title: "Select profile image", message: "Choose which way you would like to add an image", preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: handleAddNewImage(_:)))
        controller.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: handleAddFromLibrary(_:)))
        
        // allow removal of current image
        if !profileImageDataStructure.isEmpty {
            controller.addAction(UIAlertAction(title: "Remove profile picture", style: .destructive) {_ in
                serverFileUserImageDeletion(profilePickReference: self.profileImage)
                self.switchView()
            })
        }
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        didEditImage = true
        present(controller, animated: true)
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
