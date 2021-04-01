//
//  MainPageViewController.swift
//  SimplifierApp
//
//  Created by Олеся Мартынюк on 07.03.2021.
//

import UIKit


class MainPageViewController: UIViewController {

   
    @IBOutlet weak var defaultTextField: UITextView!
    @IBOutlet weak var simplifiedTextField: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    @IBAction func simplifyButtonPressed(_ sender: Any) {
        let url = URL(string: "https://test-simplifier.herokuapp.com/simplify")
        guard let requestUrl = url else { fatalError() }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        let postString = "text=\(defaultTextField.text!)";
        request.httpBody = postString.data(using: String.Encoding.utf8);
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n\(dataString)")
                    DispatchQueue.main.async {
                        self.simplifiedTextField.text = dataString
                    }
                }
        }
        task.resume()
    }
    
    @IBAction func bookmarksButtonPressed(_ sender: Any) {
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
    }
}
