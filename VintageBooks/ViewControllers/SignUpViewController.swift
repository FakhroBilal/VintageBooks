//
//  SignUpViewController.swift
//  VintageBook
//
//  Created by Bilal Fakhro on 2018-11-26.
//  Copyright © 2018 Bilal Fakhro. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    var selectedImageFromPicker: UIImage?

    var ref: DatabaseReference?
    let userID = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         //CLICK PROFILE IMAGE FOR CHANGE PICTURE
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SignUpViewController.handleSelectProfileImageView))
        profileImage.addGestureRecognizer(tapGesture)
        profileImage.isUserInteractionEnabled = true
        
        // SIGN UP BUTTON I DISABLE AT VIEW APPEAR
        signUpButton.isEnabled = false
        // TEXTFIELDS IS EMPTY FUNCTION
        handleTextField()
    }
    
    // EMPTY TEXTFIELDS , SIGN UP BUTTON DISABALD
    func handleTextField() {
        nameTextField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
        emailTextField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(SignUpViewController.textFieldDidChange), for: UIControl.Event.editingChanged)
    }
    
    // KEYBOARD DISMISS ONCLICK ANYWHERE
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // IF TEXTFIELDS IS EMPTY, CHANGE BUTTON TO DISABLE AND GIVE IT A LIGHTER COLOR
    @objc func textFieldDidChange() {
        guard let fullname = nameTextField.text, !fullname.isEmpty, let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty else {
                signUpButton.setTitleColor(UIColor.black, for: UIControl.State.normal)
                signUpButton.isEnabled = false
                return
        }
        // WHEN TEXTFIELDS IS FILED THE SIGN UP BUTTON IS ENABELD
        signUpButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        signUpButton.isEnabled = true
    }

    // FIREBASE - UPPLOAD AND SAVE DATATO USER AND USERS ID AND EMAIL AND PROFILEIMAGE
    @IBAction func signUpButtonTapped(_ sender: Any) {
        view.endEditing(true)
        guard let name = nameTextField.text,
        let email = emailTextField.text,
        let password = passwordTextField.text
        else {
        print("Form is not valid")
        return
        }
    
    Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion:{ (user, error) in
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        // FIREBASE DATABASE
        guard let userID = user?.user.uid
            else {
                return
            }
        //successfully authenticated user
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child(userID).child("\(imageName).jpeg")
            
        if let profileImage = self.profileImage.image, let uploadData = profileImage.jpegData(compressionQuality: 0.1) {
            storageRef.putData(uploadData, metadata: nil, completion: { (_, err) in
            if let error = error {
                print(error)
                return
            }
            storageRef.downloadURL(completion: { (url, err) in
            if let err = err {
                print(err)
                return
            }
    guard let url = url else { return }
        let values = ["Name": name, "Email": email, "Profile_Image_Url": url.absoluteString]
                        
        self.registerUserIntoDatabaseWithUID(userID, values: values as [String : AnyObject])
                    })
                })
            }
        })
    }

    func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("Users").child(userID!)
        
        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if let err = err {
                print(err)
                return
            }
            self.dismiss(animated: true, completion: nil)
        })
    }

    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()

        picker.delegate = self
        picker.allowsEditing = true

        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func dismiss_onClick(_ sender: Any) {
        dismiss(animated: false, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            profileImage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
