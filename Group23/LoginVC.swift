//
//  LoginVC.swift
//  Group23
//
//  Created by Warren Wiser on 28/11/2022.
//

import UIKit
import FirebaseAuth

/// handles the login screen for the user
/// NOTE: derived from Warren's HW5
class LoginVC: UIViewController, UITextFieldDelegate {
    
    let loginLabelText = "Sign In"
    let signUpLabelText = "Sign Up"
    let successSegue = "authSegue"
    
    @IBOutlet weak var confirmPasswordLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var switchAuthMethod: UISegmentedControl!
    @IBOutlet weak var authBtn: UIButton!
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmPasswordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailField.delegate = self
        passwordField.delegate = self
        confirmPasswordField.delegate = self
        showLoginScreen()
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: self.successSegue, sender: nil)
                
                // reset the login screen to default to prepare for possible logout
                self.emailField.text = nil
                self.passwordField.text = nil
                self.confirmPasswordField.text = nil
                self.statusLabel.text = nil
                self.showLoginScreen()
                self.switchAuthMethod.selectedSegmentIndex = 0
            }
        }
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(recognizeSwipeGesture(recognizer:)))
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeRight)
    }
    @IBAction func recognizeSwipeGesture(recognizer: UISwipeGestureRecognizer)
    {
        if recognizer.direction == .right{
            self.tabBarController?.selectedIndex -= 1
        }
    }
    
    /// abstract function for showing either login or signup screens
    func showScreen(isLoggingIn: Bool) {
        confirmPasswordLabel.isHidden = isLoggingIn
        confirmPasswordField.isHidden = isLoggingIn
        authBtn.setTitle(isLoggingIn ? loginLabelText : signUpLabelText, for: .normal)
    }
    
    // shows the login screen, hiding the password confirmation parts
    func showLoginScreen() {
        showScreen(isLoggingIn: true)
    }
    
    // shows the signup screen, showing the password confirmation parts
    func showSignupScreen() {
        showScreen(isLoggingIn: false)
    }
    
    /// manages click on the sign in/up button
    @IBAction func handleAuthAttempt(_ sender: UIButton) {
        let password = passwordField.text!
        switch switchAuthMethod.selectedSegmentIndex {
        case 0:
            // attempts to sign in user
            Auth.auth().signIn(withEmail: emailField.text!, password: password, completion: self.handleAuthError)
        case 1:
            // ensures the passwords are the same
            if password != confirmPasswordField.text! {
                self.statusLabel.text = "Passwords do not match"
            } else {
                // attempt to create a user
                Auth.auth().createUser(withEmail: emailField.text!, password: password, completion: self.handleAuthError)
            }
        default:
            break
        }
    }
    
    /// changes to logging in or signing up with the picker at the top
    @IBAction func handleAuthChange(_ sender: Any) {
        statusLabel.text = ""
        switch switchAuthMethod.selectedSegmentIndex {
        case 0:
            showLoginScreen()
        case 1:
            showSignupScreen()
        default:
            break
        }
    }
    
    /// shows error messages if found
    func handleAuthError(auth: AuthDataResult?, error: Error?) {
        if let error = error as NSError? {
            self.statusLabel.text = error.localizedDescription
        } else {
            self.statusLabel.text = ""
        }
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
