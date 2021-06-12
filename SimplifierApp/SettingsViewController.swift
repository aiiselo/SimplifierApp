//
//  SettingsViewController.swift
//  SimplifierApp
//
//  Created by Олеся Мартынюк on 07.03.2021.
//

import UIKit
import FirebaseAuth
import Firebase


struct Theme {
    let textColor: UIColor
    let backgroundColor: UIColor
    let buttonColor: UIColor
    let textField: UIColor
    
    static let light = Theme(textColor: .black, backgroundColor: UIColor(hexString: "#F6F5FF"), buttonColor: .blue, textField: .white)
    static let dark = Theme(textColor: .white, backgroundColor: UIColor(hexString: "#2a2b2e"), buttonColor: .orange, textField: UIColor(hexString: "#58585b"))
}

class SettingsViewController: UITableViewController {

    @IBOutlet weak var themeLabel: UILabel!
    @IBOutlet weak var themeSwitch: UISwitch!
    @IBOutlet weak var deleteBookmarksButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet var tableViewSettings: UITableView!
    let user = Auth.auth().currentUser
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.restoreSwitchState()
        self.darkModeAction(themeSwitch)
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveSwitchesStates), name: NSNotification.Name(rawValue: "saveSwitchesStatesNotification"), object: nil);
        themeSwitch.addTarget(self, action: #selector(darkModeAction), for: .touchUpInside)
        
        let name = Notification.Name("darkModeHasChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(switchTheme), name: name, object: nil)
        
        switchTheme()
    }
    
    @objc func switchTheme() {
        let isLightMode = UserDefaults.standard.bool(forKey: "isLightMode")
        let currentTheme = isLightMode ? Theme.light : Theme.dark
        view.backgroundColor = currentTheme.backgroundColor
        themeLabel.textColor = currentTheme.textColor
        deleteBookmarksButton.tintColor = currentTheme.buttonColor
        logOutButton.tintColor = currentTheme.buttonColor
        tableViewSettings.backgroundColor = currentTheme.backgroundColor
        tableViewSettings.visibleCells.forEach { cell in
            cell.backgroundColor = currentTheme.backgroundColor
            cell.backgroundView?.backgroundColor = currentTheme.backgroundColor
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isLightMode = UserDefaults.standard.bool(forKey: "isLightMode")
        let currentTheme = isLightMode ? Theme.light : Theme.dark
        cell.backgroundColor = currentTheme.backgroundColor
        cell.backgroundView?.backgroundColor = currentTheme.backgroundColor
    }
    
    @objc func darkModeAction(_ toggle: UISwitch) {
        let name = Notification.Name("darkModeHasChanged")
        UserDefaults.standard.set(toggle.isOn, forKey: "isLightMode")
        NotificationCenter.default.post(name: name, object: nil)
    }
    
    @objc func saveSwitchesStates(){
        UserDefaults.standard.set(themeSwitch!.isOn, forKey: "themeSwitch")
        UserDefaults.standard.synchronize()
    }
    
    func restoreSwitchState(){
        themeSwitch!.isOn = UserDefaults.standard.bool(forKey: "themeSwitch");
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "saveSwitchesStatesNotification"), object: nil);
    }
    
    @IBAction func deleteBookmarksButtonPressed(_ sender: Any) {
        appearAlert()
    }
    
    func appearAlert() {
        let alert = UIAlertController(title: "", message: "Are you sure? All bookmarks will be permanently deleted .", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            if let user = self.user {
                let uid = user.uid
                let ref = Database.database().reference(fromURL: "https://textsimplifier-default-rtdb.firebaseio.com/")
                let usersReference = ref.child("users").child(uid).child("favourites")
                usersReference.removeValue()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        self.present(alert, animated: true)
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
