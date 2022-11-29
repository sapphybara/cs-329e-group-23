//
//  LoginVC.swift
//  Group23
//
//  Created by m1 on 28/11/2022.
//

import UIKit
import FirebaseAuth

/// handles the login screen for the user
/// NOTE: derived from Warren's HW5
class LoginVC: UIViewController {
    
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
    
}
