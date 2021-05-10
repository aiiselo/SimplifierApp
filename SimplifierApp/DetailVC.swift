//
//  DetailVC.swift
//  SimplifierApp
//
//  Created by Олеся Мартынюк on 10.05.2021.
//

import UIKit

class DetailVC: UIViewController {
    
    @IBOutlet weak var defaultText: UITextView!
    @IBOutlet weak var simplifiedText: UITextView!
    
    var note: Bookmarks?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            DispatchQueue.main.async {
                self.defaultText.text = self.note?.preview
                self.simplifiedText.text = self.note?.simplification
            }
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
}
