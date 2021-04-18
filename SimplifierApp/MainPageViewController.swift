//
//  MainPageViewController.swift
//  SimplifierApp
//
//  Created by Олеся Мартынюк on 07.03.2021.
//

import UIKit
import Vision

class MainPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
       
    @IBOutlet weak var defaultTextField: UITextView!
    
    @IBOutlet weak var simplifiedTextField: UITextView!
    var textImage = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
    
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.textImage = pickedImage
            recognizeText(image: pickedImage)
        }
        print("ImageTaken")
        picker.dismiss(animated: true, completion: nil)
        
    }
      
    
    
}
