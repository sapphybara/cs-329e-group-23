//
//  ProfileVC.swift
//  Group23
//
//  Created by m1 on 06/10/2022.
//

import UIKit
import FirebaseAuth

class ProfileVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // keyboard delegation initializers
        usernameField.delegate = self
        passwordField.delegate = self
        passwordField.isSecureTextEntry = true
        
        Auth.auth().addStateDidChangeListener() {
            auth, user in
            if user != nil {
                self.usernameField.text = nil
                self.passwordField.text = nil
                self.performSegue(withIdentifier: "LoginSegue", sender: nil) // perform segue if user is logged in
            }
        }
        
    }
    
    // If user presses the login button do the following
    @IBAction func loginButtonPressed(_ sender: Any) {
        Auth.auth().signIn(withEmail: usernameField.text!, password: passwordField.text!) {
            authResult, error in
            if let error = error as NSError? {
                self.errorMessage.text = "\(error.localizedDescription)"
                } else {
                    self.errorMessage.text = ""
                }
            }
        }
    
    // If user presses the create account button do the following
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "New User?", message: "Create An Account Below" , preferredStyle: .alert)
       
        alert.addTextField() { // textFields[0]
           tfEmail in
           tfEmail.placeholder = "Enter Your Email"
        }
       
        alert.addTextField() { // textFields[1]
           tfPassword in
           tfPassword.isSecureTextEntry = true
           tfPassword.placeholder = "Enter Your Password"
        }
       
        let saveAction = UIAlertAction(title: "Save", style: .default) {
           _ in
           let emailField = alert.textFields![0]
           let passwordField = alert.textFields![1]
           // Above creates a new user in Firebase
           
           Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) {
               // Tries to create a user and outputs error message if inputs are no good
               authResult, error in
               if let error = error as NSError? {
                   self.errorMessage.text = "\(error.localizedDescription)"
               } else {
                   self.errorMessage.text = ""
               }
           }
        }
       
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alert.addAction(saveAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    // User Hits Return - Deactivate Keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // User Touches Screen Area With Keyboard Active - Deactivate Keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
