//
//  MainPageViewController.swift
//  SimplifierApp
//
//  Created by Олеся Мартынюк on 07.03.2021.
//

import UIKit
import Vision
import FirebaseAuth
import Firebase

class MainPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    let user = Auth.auth().currentUser
    var textImage = UIImage()
    
    @IBOutlet weak var addToBookMarksButton: UIButton!
    @IBOutlet weak var defaultTextField: UITextView!
    @IBOutlet weak var simplifiedTextField: UITextView!
    @IBOutlet weak var clearTextButton: UIButton!
    @IBOutlet weak var takePhotoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearTextButton.isHidden = true
        addToBookMarksButton.isHidden = true
        
        defaultTextField.text = "Your text"
        defaultTextField.textColor = UIColor.lightGray
        defaultTextField.delegate = self
        defaultTextField.returnKeyType = .done
        
        simplifiedTextField.text = "Simplified text"
        simplifiedTextField.textColor = UIColor.lightGray
        simplifiedTextField.delegate = self
        
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
    // MARK: - Button Actions
    
    @IBAction func clearTextButtonPressed(_ sender: Any) {
        if defaultTextField.isFirstResponder {
            defaultTextField.text = ""
        }
        else {
            defaultTextField.text = "Your text"
            defaultTextField.textColor = UIColor.lightGray
            clearTextButton.isHidden = true
            takePhotoButton.isHidden = false
        }
    }
    
    @IBAction func simplifyButtonPressed(_ sender: Any) {
        if defaultTextField.text != nil && defaultTextField.text != "Your text" && defaultTextField.text != "" {
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
                            self.addToBookMarksButton.setBackgroundImage(UIImage(systemName: "bookmark"), for: UIControl.State.normal)
                            self.addToBookMarksButton.isHidden = false
                            self.simplifiedTextField.textColor = UIColor.black
                        }
                    }
            }
            task.resume()
        }
        if defaultTextField.text == "Your text" {
            simplifiedTextField.text = "Simplified text"
            simplifiedTextField.textColor = UIColor.lightGray
            addToBookMarksButton.isHidden = true
        }
    }
    
    @IBAction func bookmarksButtonPressed(_ sender: Any) {
    }
    
    @IBAction func addToBookmarksButtonPressed(_ sender: Any) {
        if addToBookMarksButton.currentBackgroundImage == UIImage(systemName: "bookmark"){
            addToBookMarksButton.setBackgroundImage(UIImage(systemName: "bookmark.fill"), for: UIControl.State.normal)
            saveSimplification()
        }
        else {
            addToBookMarksButton.setBackgroundImage(UIImage(systemName: "bookmark"), for: UIControl.State.normal)
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func settingsButtonPressed(_ sender: Any) {
        
    }
    
    // MARK: - Other functions
    
    private func recognizeText(image: UIImage?) {
        guard let cgImage = image?.cgImage else { return }
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation], error == nil else {
                return
            }
            
            let text = observations.compactMap({
                $0.topCandidates(1).first?.string
            }).joined(separator: ", ")
            print(text)
            self.defaultTextField.text = text
        }
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    func saveSimplification(){
        if defaultTextField.text != nil && simplifiedTextField.text != nil {
            if let user = user {
                let uid = user.uid
                let ref = Database.database().reference(fromURL: "https://textsimplifier-default-rtdb.firebaseio.com/")
                let usersReference = ref.child("users").child(uid).child("favourites")
                let values = [defaultTextField.text! : simplifiedTextField.text!]
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
    
    func deleteSimplification(){
        
    }
    
    // MARK: -UIImagePickerDelegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.textImage = pickedImage
            recognizeText(image: pickedImage)
        }
        print("ImageTaken")
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: - UITextViewDelegates
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Your text" {
            textView.text = ""
            textView.textColor = UIColor.black
            clearTextButton.isHidden = false
            takePhotoButton.isHidden = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Your text"
            textView.textColor = UIColor.lightGray
        }
        if textView.text == "Your text" {
            clearTextButton.isHidden = true
            takePhotoButton.isHidden = false
        }
        else {
            clearTextButton.isHidden = false
            takePhotoButton.isHidden = true
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
}
