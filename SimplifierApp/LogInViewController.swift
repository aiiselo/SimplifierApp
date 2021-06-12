//
//  LogInViewController.swift
//  SimplifierApp
//
//  Created by Олеся Мартынюк on 07.03.2021.
//

import UIKit
import FirebaseAuth
import Firebase

class LogInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0
    }
    
    func checkValidFields() -> String? {
        if emailTextField.text == "" || emailTextField.text == nil ||
            passwordTextField.text == "" || passwordTextField.text == nil {
            return "Please, fill in all the fields"
        }
        return nil
    }
    
    @IBAction func signInButtonPressed(_ sender: Any) {
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
            self.errorLabel.alpha = 0
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) {
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
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let secondVC = storyboard.instantiateViewController(identifier: "MainPageViewController") as! MainPageViewController
                    self.view.window?.rootViewController = secondVC
                }
            }
        }
    }
}
