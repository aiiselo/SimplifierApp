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
    
    @IBOutlet weak var defaultText: UITextView!
    @IBOutlet weak var simplifiedText: UITextView!
    @IBOutlet weak var saveChangesButton: UIStackView!
    
    var note: Bookmarks?
    let user = Auth.auth().currentUser
    let ref = Database.database().reference(fromURL: "https://textsimplifier-default-rtdb.firebaseio.com/")
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.defaultText.layer.cornerRadius = 6
        self.defaultText.layer.borderWidth = 0
        self.defaultText.layer.borderColor = UIColor(hexString: "#FE9600").cgColor
        self.defaultText.delegate = self
        self.defaultText.textContainerInset.left = 8
        self.defaultText.textContainerInset.top = 12
        self.defaultText.textContainerInset.right = 32
        self.defaultText.returnKeyType = .done
        
        self.simplifiedText.layer.cornerRadius = 6
        self.simplifiedText.layer.borderWidth = 0
        self.simplifiedText.delegate = self
        self.simplifiedText.layer.borderColor = UIColor(hexString: "#FE9600").cgColor
        self.simplifiedText.textContainerInset.left = 8
        self.simplifiedText.textContainerInset.top = 12
        self.simplifiedText.textContainerInset.right = 32
        self.simplifiedText.returnKeyType = .done
        
        DispatchQueue.main.async {
            self.defaultText.text = self.note?.preview
            self.simplifiedText.text = self.note?.simplification
        }
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
        let usersReference = ref.child("users").child(self.user!.uid).child("favourites").child((self.note?.uuid)!)
        let values = [
            "preview_text": defaultText.text!,
            "simplified_text": simplifiedText.text!,
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
