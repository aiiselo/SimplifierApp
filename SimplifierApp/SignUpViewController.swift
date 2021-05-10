//
//  SignInViewController.swift
//  SimplifierApp
//
//  Created by Олеся Мартынюк on 07.03.2021.
//

import UIKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstPasswordTextField: UITextField!
    @IBOutlet weak var secondPasswordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0
    }
    
    func checkValidFields() -> String? {
        if emailTextField.text == "" || emailTextField.text == nil ||
            firstPasswordTextField.text == "" || firstPasswordTextField.text == nil ||
            secondPasswordTextField.text == "" || secondPasswordTextField.text == nil {
            return "Please, fill in all the fields"
        }
        else
            if firstPasswordTextField.text != secondPasswordTextField.text {
                return "Passwords don't match"
            }
            else {
                return nil
                
            }
    }
    
    func appearAlert() {
        let alert = UIAlertController(title: "Registration complete", message: "Log in the system now", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let secondVC = storyboard.instantiateViewController(identifier: "AuthViewController") as! AuthViewController
            self.navigationController?.pushViewController(secondVC, animated: true)
        }))
        self.present(alert, animated: true)
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        let result = checkValidFields()
        if result != nil {
            errorLabel.alpha = 1
            errorLabel.numberOfLines = 0
            errorLabel.textColor = .red
            errorLabel.lineBreakMode = .byWordWrapping
            errorLabel.text = result
            errorLabel.sizeToFit()
        }
        else {
            Auth.auth().createUser(withEmail: emailTextField.text!, password: firstPasswordTextField.text!) {
                (result, error) in
                if error != nil {
                    self.errorLabel.alpha = 1
                    self.errorLabel.numberOfLines = 0
                    self.errorLabel.textColor = .red
                    self.errorLabel.lineBreakMode = .byWordWrapping
                    self.errorLabel.text = error?.localizedDescription
                    self.errorLabel.sizeToFit()
                }
                else {
                    self.errorLabel.alpha = 0
                    let db = Firestore.firestore()
                    db.collection("users").addDocument(data: [
                        "email": self.emailTextField.text!,
                        "password": self.firstPasswordTextField.text!,
                        "uid": result!.user.uid
                    ]) { (error) in
                        if error != nil {
                            self.errorLabel.alpha = 1
                            self.errorLabel.textColor = .red
                            self.errorLabel.text = "Saving user error"
                        }
                        else {
                            self.appearAlert()
                        }
                    }
                    let ref = Database.database().reference(fromURL: "https://textsimplifier-default-rtdb.firebaseio.com/")
                    let usersReference = ref.child("users").child(result!.user.uid)
                    let values = [
                        "email": self.emailTextField.text!,
                        "name" : "Somename"
                    ]
                    usersReference.updateChildValues(values, withCompletionBlock: {
                        (error, ref) in
                        if error != nil {
                            print(error)
                            return
                        }
                    })
                    
                }
            }
        }
    }
    
    
    

}

