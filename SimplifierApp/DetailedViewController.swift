//
//  DetailVC.swift
//  SimplifierApp
//
//  Created by Олеся Мартынюк on 10.05.2021.
//

import UIKit
import FirebaseAuth
import Firebase

class DetailedViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var defaultTextField: UITextView!
    @IBOutlet weak var simplifiedTextField: UITextView!
    @IBOutlet weak var saveChangesButton: UIStackView!
    @IBOutlet weak var defaultTextLabel: UILabel!
    @IBOutlet weak var simplifiedTextLabel: UILabel!

    var note: Bookmarks?
    let user = Auth.auth().currentUser
    let ref = Database.database().reference(fromURL: "https://textsimplifier-default-rtdb.firebaseio.com/")
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let name = Notification.Name("darkModeHasChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(switchTheme), name: name, object: nil)
        
        self.defaultTextField.layer.cornerRadius = 6
        self.defaultTextField.layer.borderWidth = 0
        self.defaultTextField.layer.borderColor = UIColor(hexString: "#FE9600").cgColor
        self.defaultTextField.delegate = self
        self.defaultTextField.textContainerInset.left = 8
        self.defaultTextField.textContainerInset.top = 12
        self.defaultTextField.textContainerInset.right = 32
        self.defaultTextField.returnKeyType = .done
        
        self.simplifiedTextField.layer.cornerRadius = 6
        self.simplifiedTextField.layer.borderWidth = 0
        self.simplifiedTextField.delegate = self
        self.simplifiedTextField.layer.borderColor = UIColor(hexString: "#FE9600").cgColor
        self.simplifiedTextField.textContainerInset.left = 8
        self.simplifiedTextField.textContainerInset.top = 12
        self.simplifiedTextField.textContainerInset.right = 32
        self.simplifiedTextField.returnKeyType = .done
        
        switchTheme()
        
        DispatchQueue.main.async {
            self.defaultTextField.text = self.note?.preview
            self.simplifiedTextField.text = self.note?.simplification
        }
    }
    
    @objc func switchTheme() {
        let isLightMode = UserDefaults.standard.bool(forKey: "isLightMode")
        let theme = isLightMode ? Theme.light : Theme.dark
        view.backgroundColor = theme.backgroundColor
        
        if defaultTextField.text == "Your text"  {
            defaultTextField.textColor = UIColor.lightGray
        }
        else {
            defaultTextField.textColor = theme.textColor
        }
        
        if simplifiedTextField.text == "Simplified text" {
            simplifiedTextField.textColor = UIColor.lightGray
        }
        else {
            simplifiedTextField.textColor = theme.textColor
        }
        
        defaultTextLabel.textColor = theme.textColor
        simplifiedTextLabel.textColor = theme.textColor
        defaultTextField.backgroundColor = theme.textField
        simplifiedTextField.backgroundColor = theme.textField
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 2
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 0
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
    
    @IBAction func saveChangesButtonPressed(_ sender: Any) {
        if defaultTextField.text != nil && simplifiedTextField.text != nil && defaultTextField.text != "" && simplifiedTextField.text != "" {
            let usersReference = ref.child("users").child(self.user!.uid).child("favourites").child((self.note?.uuid)!)
            let values = [
                "preview_text": defaultTextField.text!,
                "simplified_text": simplifiedTextField.text!,
            ] as [String : Any]
            
            usersReference.updateChildValues(values, withCompletionBlock: {
                (error, ref) in
                if error != nil {
                    return
                }
                else {
                    NotificationCenter.default.post(name: .didUpdateBookmark, object: nil)
                }
            })
        }
    }
}
