//
//  ViewController.swift
//  Memevers1.0
//
//  Created by Victor Lúcio Silvano on 31/07/21.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textFieldTop: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var textFieldBottom: UITextField!
    @IBOutlet weak var toolbarBottom: UIToolbar!
    @IBOutlet weak var toolbarTop: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "Impact", size: 40)!,
        NSAttributedString.Key.strokeWidth: -5.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defineTextField(textFieldTop, "TOP")
        defineTextField(textFieldBottom, "BOTTOM")
        
        shareButton.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeTokeyboardNotifications()
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func pickAnImage(_ sender: Any) {
        pickImage(source: .photoLibrary)
    }
    
    @IBAction func pickImageCamera(_ sender: Any) {
        pickImage(source: .camera)
    }
    
    func pickImage(source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController ()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func shareImage(_ sender: Any) {
        
        let image = generateMemedImage()
        let activityVC = UIActivityViewController(activityItems:[image], applicationActivities: nil)
        activityVC.completionWithItemsHandler = {(activity, success, items, error) in
            if success {
                self.save()
                self.dismiss(animated: true, completion: nil)
            } else if (error != nil) {
                print(error!)
            }
            
        }
        present(activityVC, animated: true, completion: nil)
        
    }
    
    @IBAction func cancelEditing(_ sender: Any) {
        imageView.image = nil
        textFieldTop.text = "TOP"
        textFieldBottom.text = "BOTTOM"
        shareButton.isEnabled = false
        dismiss(animated: true, completion: nil)
        
        
    }
    
    func defineTextField(_ textField: UITextField,_ text: String) {
        textField.delegate = self
        textField.text = text
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info [UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = image
            dismiss(animated: true, completion: nil)
            shareButton.isEnabled = true
            
        } else {
            shareButton.isEnabled = false
        }
    }
    
    func subscribeTokeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification:Notification)  {
        if textFieldBottom.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textFieldTop.text == "TOP" && textFieldTop.isTouchInside == true {
            textFieldTop.text = ""
        }
        if textFieldBottom.text == "BOTTOM" && textFieldBottom.isTouchInside == true {
            textFieldBottom.text = ""
        }
    }
    
    func save() {
        _ = Meme(topText: textFieldTop.text!, bottomText: textFieldBottom.text!, originalImage: imageView.image!, memedImage: generateMemedImage())
        
    }
    
    func generateMemedImage() -> UIImage {
        hideShow(true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        hideShow(false)
        
        return memedImage
    }
    
    func hideShow(_ isHidden: Bool) {
        toolbarBottom.isHidden = isHidden
        toolbarTop.isHidden = isHidden
    }
}





