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
    var latestUUID: String = ""
    
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
        defaultTextField.layer.cornerRadius = 6
        defaultTextField.layer.borderWidth = 0
        defaultTextField.layer.borderColor = UIColor(hexString: "#FE9600").cgColor
        defaultTextField.textContainerInset.left = 8
        defaultTextField.textContainerInset.top = 12
        defaultTextField.textContainerInset.right = 32
        
        simplifiedTextField.text = "Simplified text"
        simplifiedTextField.textColor = UIColor.lightGray
        simplifiedTextField.delegate = self
        simplifiedTextField.layer.cornerRadius = 6
        simplifiedTextField.layer.borderWidth = 0
        simplifiedTextField.layer.borderColor = UIColor(hexString: "#FE9600").cgColor
        simplifiedTextField.textContainerInset.left = 8
        simplifiedTextField.textContainerInset.top = 12
        simplifiedTextField.textContainerInset.right = 32
        
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
            simplifiedTextField.text = "Loading . . ."
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
            deleteSimplification()
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
            self.defaultTextField.textColor = UIColor.black
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
                let today = Date()
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm E, d MMM y"
                let ref = Database.database().reference(fromURL: "https://textsimplifier-default-rtdb.firebaseio.com/")
                self.latestUUID = UUID().uuidString
                let usersReference = ref.child("users").child(uid).child("favourites").child(latestUUID)
                let values = [
                    "preview_text": defaultTextField.text!,
                    "simplified_text": simplifiedTextField.text!,
                    "date": formatter.string(from: today)
                ] as [String : Any]
                usersReference.updateChildValues(values, withCompletionBlock: {
                    (error, ref) in
                    if error != nil {
                        return
                    }
                })
            }
        }
    }
    
    func deleteSimplification(){
        if let user = user {
            let uid = user.uid
            let ref = Database.database().reference(fromURL: "https://textsimplifier-default-rtdb.firebaseio.com/")
            let usersReference = ref.child("users").child(uid).child("favourites").child(latestUUID)
            usersReference.removeValue()
        }
    }
    
    // MARK: -UIImagePickerDelegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.textImage = pickedImage
            recognizeText(image: pickedImage)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITextViewDelegates
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 2
        if textView.text == "Your text" {
            textView.text = ""
            textView.textColor = UIColor.black
            clearTextButton.isHidden = false
            takePhotoButton.isHidden = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        defaultTextField.layer.borderWidth = 0
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

