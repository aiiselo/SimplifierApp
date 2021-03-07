//
//  MainPageViewController.swift
//  SimplifierApp
//
//  Created by Олеся Мартынюк on 07.03.2021.
//

import UIKit

class MainPageViewController: UIViewController {

    @IBOutlet weak var defaultTextField: UITextField!
    @IBOutlet weak var simplifiedTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    @IBAction func simplifyButtonPressed(_ sender: Any) {
    }
    @IBAction func bookmarksButtonPressed(_ sender: Any) {
    }
    @IBAction func settingsButtonPressed(_ sender: Any) {
    }
}
