//
//  SignInViewController.swift
//  VintageBook
//
//  Created by Bilal Fakhro on 2018-11-26.
//  Copyright © 2018 Bilal Fakhro. All rights reserved.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    var ref: DatabaseReference?
    let userID = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // SIGN UP BUTTON I DISABLE AT VIEW APPEAR
        signInButton.isEnabled = false
        // TEXTFIELDS IS EMPTY FUNCTION
        handleTextField()
    }
    
    // EMPTY TEXTFIELDS , SIGN UP BUTTON DISABALD
    func handleTextField() {
        emailTextField.addTarget(self, action: #selector(SignInViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignInViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    // IF TEXTFIELDS IS EMPTY, CHANGE BUTTON TO DISABLE AND GIVE IT A LIGHTER COLOR
    @objc func textFieldDidChange() {
        guard let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty else {
                signInButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
                signInButton.isEnabled = false
                return
        }
        // WHEN TEXTFIELDS IS FILED THE SIGN UP BUTTON IS ENABELD
        signInButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        signInButton.isEnabled = true
    }
    
    // KEYBOARD DISMISS ONCLICK ANYWHERE
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // ALLOW USER TO STAY LOGGED ALL THE TIME UNTIL LOGOUT
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "signInToCardSegue", sender: self)
        }
    }
    
    @IBAction func signInButtonTapped(_ sender: Any) {
        view.endEditing(true)
        AuthService.signIn(email: emailTextField.text!, password: passwordTextField.text!, onSuccess: {
            self.performSegue(withIdentifier: "signInToCardSegue", sender: self)
        }, onError: {error in
            print(error)
        })
    }
    
    @IBAction func dontHaveAccountButton(_ sender: UIButton) {
    }
}
