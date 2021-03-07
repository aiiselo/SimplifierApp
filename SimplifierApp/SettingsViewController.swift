//
//  SettingsViewController.swift
//  SimplifierApp
//
//  Created by Олеся Мартынюк on 07.03.2021.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UITableViewController {

    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var themeSwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func appearAlert() {
        let alert = UIAlertController(title: "", message: "Are you sure? All bookmarks will be deleted.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func deleteBookmarksButtonPressed(_ sender: Any) {
        appearAlert()
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondVC = storyboard.instantiateViewController(identifier: "AuthViewController") as! AuthViewController
        self.view.window?.rootViewController = secondVC
        
    }
    
}
