//
//  EditViewController.swift
//  BelajarCoreData
//
//  Created by zein rezky chandra on 06/04/21.
//

import UIKit

protocol EditViewControllerDelegate: class {
    func updateArray(productArray: [ProductModel], prevProdName: String)
}

class EditViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var productPriceTxt: UITextField!
    @IBOutlet weak var productNameTxt: UITextField!
    @IBOutlet weak var productImage: UIImageView!
    
    var products = [ProductModel]()
    var indexOf = 0
    var prevProductName = ""
    var imagePickerController = UIImagePickerController()
    
    weak var delegate: EditViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    func setupView() {
        productImage.image = UIImage(named: products[indexOf].productImage)
        productNameTxt.text = products[indexOf].productName
        productPriceTxt.text = "\(products[indexOf].productPrice)"
        
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = ["public.image"]
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: UIButton) {
        self.delegate?.updateArray(productArray: products, prevProdName: prevProductName)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openGalleryAction(_ sender: UIButton) {
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let imageSelected = info[.editedImage] as? UIImage else { return }
        productImage.image = imageSelected
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == productNameTxt {
            products[indexOf].productName = textField.text!
            productPriceTxt.becomeFirstResponder()
        } else {
            products[indexOf].productPrice = Int(textField.text!) ?? 0
            textField.resignFirstResponder()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == productNameTxt {
            products[indexOf].productName = textField.text!
            productPriceTxt.becomeFirstResponder()
        } else {
            products[indexOf].productPrice = Int(textField.text!) ?? 0
            textField.resignFirstResponder()
        }
        return true
    }
    
}
