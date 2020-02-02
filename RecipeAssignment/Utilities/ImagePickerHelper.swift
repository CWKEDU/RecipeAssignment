//
//  ImagePickerHelper.swift
//  RecipeAssignment
//
//  Created by Black Dragon on 02/02/2020.
//  Copyright © 2020 Black Dragon. All rights reserved.
//

import UIKit


//MARK:- Custom Error
enum ImagePickerHelperError : Error {
    case FailGetImage(String)
    case UserCancelled(String)
}



//MARK:- Delegate
protocol ImagePickerHelperDelegate : NSObject {
    func imageResult(image : UIImage?, error : ImagePickerHelperError?)
}




//MARK:- Class Main
class ImagePickerHelper : NSObject {
    
    //MARK:- Vars
    private lazy var imagePicker : UIImagePickerController = {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        return pickerController
    }()
    private var vc : UIViewController?
    weak var delegate : ImagePickerHelperDelegate?
}



//MARK:- Main Call Function
extension ImagePickerHelper {
    
    func showPickImageOption(vc : UIViewController) {
        self.vc = vc
        DispatchQueue.main.async {
            self.showAddImageOption()
        }
    }
    
}




//MARK:- Private Helper Functions
private extension ImagePickerHelper {
    
    func showAddImageOption() {
        
        guard let vc = vc else {
            setGetImageFailError(message: "View controller missing")
            return
        }
        
        let alert = UIAlertController(title: "Add Photo", message: "Please choose a method to add photo", preferredStyle: .actionSheet)
        let actionCamera = UIAlertAction(title: "Use Camera", style: .default) { (action) in
            self.showCamera()
        }
        let actionPicker = UIAlertAction(title: "Use Photo Library", style: .default) { (action) in
            self.showImagePicker()
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(actionCamera)
        alert.addAction(actionPicker)
        alert.addAction(actionCancel)
        
        vc.present(alert, animated: true, completion: nil)
    }
    
    
    func showCamera() {
        guard let vc = vc else {
            setGetImageFailError(message: "View controller missing")
            return
        }
        
        imagePicker.sourceType = .camera
        vc.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func showImagePicker() {
        guard let vc = vc else {
            setGetImageFailError(message: "View controller missing")
            return
        }
        
        imagePicker.sourceType = .photoLibrary
        vc.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func setGetImageFailError(message : String) {
        delegate?.imageResult(image: nil, error: ImagePickerHelperError.FailGetImage(message))
    }
}



//MARK:- UIImagePickerControllerDelegate
extension ImagePickerHelper : UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let vc = vc else {
            setGetImageFailError(message: "View controller missing")
            return
        }
        vc.dismiss(animated: true, completion: nil)
        
        guard let image = info[.originalImage] as? UIImage else {
            setGetImageFailError(message: "Original image missing")
            return
        }
        
        delegate?.imageResult(image: image, error: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        delegate?.imageResult(image: nil, error: ImagePickerHelperError.UserCancelled("User cancelled"))
    }
}


extension ImagePickerHelper : UINavigationControllerDelegate {
    
}

